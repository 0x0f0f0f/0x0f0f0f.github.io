@def title = "Really fast Markov chains in ~20 lines of sh, grep, cut and awk"
@def rss =  "Really fast Markov chains in ~20 lines of sh, grep, cut and awk"
@def published = "09 November 2019"
@def tags = ["markov-chains", "probability", "haskell", "shell"]

{{post_header}}

Some days ago, driven by boredom, I implemented my own Markov chains in Haskell by following this great [tutorial](https://dschrempf.github.io/coding/2018-02-10-markov-chains-in-haskell/). Markov chains can be a way of implementing really fun "dumb" group chat bots, that can generate new random messages that sound realistic based on the previous history of the chat. From Wikipedia:

> A Markov chain is a stochastic model describing a sequence of possible events in which the probability of each event depends only on the state attained in the previous event.

Here's a [great article](http://setosa.io/ev/markov-chains/) introducing the concept of Markov chains. In the case of a group chat bot, each state (or node of the graph) is one of the words that was previously sent in the messages, and each probability of transition towards another state (word) is based on the frequency of the first word (transition's source state) being followed by the second one (the transition's destination state).

After coding a simple Markov chain on words in Haskell, I've noticed that it was really slow and resource intensive even on a few thousand of messages. This was because the model was calculated by summing the frequency of word pairs and it was kept in memory inside of a `Data.Map` structure.

Although the Haskell implementation can get much faster if optimized, my friend [Francesco](https://github.com/Francesco149) showed me his amazing implementation of Markov chains on words made **in plain sh and awk**, in ~20 lines of code.\

### [markov.sh](https://github.com/Francesco149/markov.sh)

His project is split in 2 programs. The first one, `mrkfeed.awk` is a really simple `awk` program that separates words on a line into pairs of words, separated line by line.

```awk
#!/usr/bin/awk -f

{
  for (i = 1; i < NF; i++) {
    print $i,$(i+1)
  }
  print $i
}
```


For example, let's take this simple chat log (referred to as `chatlog.txt`):

```
hello everybody
hi people
hello people
how are you
how are things going
```

The first step is creating a model for the Markov chain. Here's what will be into the model file when we run `./mrkfeed.awk < chatlog.txt >> model.mrkdb`,  (piped into `sort` for readability)
```
are things
are you
everybody
going
hello everybody
hello people
hi people
how are
how are
people
people
things going
you
```

The next step is generating a new random message with `./mrkwords.sh model.mrkdb 50 | tr '\n' ' ' && echo`

At first, `mrkwords.sh` will pick a random line from the model and pick the first word of the pair as the first word of our output message. After this, it will filter the model to find what word pairs start with the first word it picked. Let's say it picked the word `hello` as the first word of the message. It will then randomly choose the second word of the message from the second element of a pair in the model that starts with the first word it chose. In this case, since it picked `hello` as the first word, it may pick one between `everybody` and `people` as the next word.
It then repeats this process by passing the last word it chose as the word to choose in the next iteration. It may be even easier to understand in terms of code than in plain words.

The presence of duplicate lines in the model is what gives it the power of weighed probability, perfectly modeling the process of random extraction, making the generated models real Markov chains.
Doing this with plain unix tools makes `markov.sh` incredibly fast, because it is sacrificing disk space by storing duplicates in exchange for a huge improvement in the complexity of the computations. Although Markov chains are often considered complex, this small shell program shines in showing the real underlying simplicity.

Here's a commented version of `./mrkwords.sh`
```bash
#!/bin/sh

# choose the first argument as the model file or try to open '.mrkdb'
file="${1:-~/.mrkdb}"

# $n is the maximum number of remaining words (iterations)
# it is the 2nd argument of this program
n="${2:-1}"

# if present, use $key (3rd argument) to find pairs starting
# with it in the model, you may use this to force a
# word as the first word of the message
key="$3"

# if $key is set print it
[ ! -z "$key" ] && echo "$key"

# the max remaining number of words cannot be equal or less to 0
[ "$n" -le 0 ] && exit

# if key is not set, set the chosen word to the first element
# of a random pair in the model
if [ -z "$key" ]; then
  word=$(shuf -n 1 < "$file" | cut -d' ' -f1)

# otherwise (key is set)
else
    # step 1, filter the model to find lines containing $key
    # step 2, use awk to get only the lines in the model
    # beginning with $key (the first element of the pairs)
    # step 3, after filtering out the model, pick the second element of
    # a random pair and set it as the value of the variable $word
  word=$(grep -Fw "$key" < "$file" |
    awk -v key="$key" '$1 == key { print $0 }' |
    shuf -n 1 | awk '{ print $2 }') || exit

    # if $word is empty then exit this iteration
    # this may also mean that the randomized step picked
    # a line in the model containing only the first element
    # (signaling the end of the process)
  [ -z "$word" ] && exit
fi

# the real magic happens here. this last step is similar
# to a recursive function call in most programming languages
# it runs this program again, with $n decremented by 1
# and with the chosen $word as the next iteration's $key
exec "$0" "$file" "$(( n - 1 ))" "$word"
```

In this example it generates a random fortune, modeled from the `goedel` fortunes contained in the famous `fortune-mod` package.
```bash
# remove the % delimiter in the fortune file and save it as a .txt
sed -e '/^%$/d' < /usr/share/fortunes/goedel >> goedel.txt
# generate the model
./mrkfeed.awk < goedel.txt >> goedelmodel.mrkdb
# get a random fortune!
./mrkwords.sh goedelmodel.mrkdb 50 | tr '\n' ' '
the dimensionality of computerized fortune-tellers!
# again!
./mrkwords.sh goedelmodel.mrkdb 50 | tr '\n' ' '
the thoughts of metalanguage are still free.
# again!
./mrkwords.sh goedelmodel.mrkdb 50 | tr '\n' ' '
# let's change the model by using all fortunes this time
./mrkwords.sh fortunesmodel.mrkdb 50 | tr '\n' ' '
low taste, and goin' insane,
```

`markov.sh` is extremely fast, even on relatively large data sets (millions of lines).
