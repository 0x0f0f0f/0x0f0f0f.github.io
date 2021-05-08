@def title = "How to turn DNA into Music"
@def published = "04 April 2020"
@def tags = ["functional-programming", "ocaml", "minicaml", "bioinformatics", "dna"]

{{post_header}}

## A Short Background

I've been playing with [bioinformatics algorithms](https://rosalind.info) and
DNA for a while during the COVID-19 lockdown. While reading a book chapter about
machine translation, a weird idea came to my mind.
I wondered if I could *procedurally translate DNA into music*. A few chapters later, the [author](https://en.wikipedia.org/wiki/G%C3%B6del,_Escher,_Bach) also draws similarities between genes and music.
It took me a few hours and a couple hundred lines of OCaml code to make
a small program that translates **FASTA** files to playable MIDI files, mapped
to an arbitrary music scale.

>In bioinformatics and biochemistry, the FASTA format is a text-based format for
>representing either nucleotide sequences or amino acid sequences, in which
>nucleotides or amino acids are represented using single-letter codes.

The `dna2music` script reads a FASTA file from standard input and outputs an
intermediate text file which contains sequences of notes, one by line, composed
by their location, octave, the note played, velocity, duration and track.

These text files can then converted to MIDI files by the handy
[txt2mid](https://github.com/alambicbicephale/txt2mid) tool, written in C++
by [Jamil Alioui](https://github.com/alambicbicephale).

## But How Does it Sound Like?

Figure: A screenshot of an Ardour session where the mp3 files were recorded.
![Ardour Screenshot](/assets/images/ardour.png)

Just to be on the Coronavirus pandemic trend, here's how the SARS-Cov-2 genome
sounds like, played in D# major at 120 beats per minute through the Open Source
[helm](https://tytel.org/helm/) software synthesizer.

<audio class="player" controls  preload="none" style="width: 100%">
    <source src="/posts/media/sarscov2.mp3" type="audio/mp3">
</audio>

Here's another take, this time on a small section of the genome of Cytomegalovirus, played in C.

<audio class="player" controls  preload="none" style="width: 100%">
    <source src="/posts/media/cytomegalovirus.mp3" type="audio/mp3">
</audio>



## How does the conversion work?

The conversion is deterministic. This means that the same FASTA file will always
produce the same MIDI file. I've tried to partially replicate some processes
that happen inside of living cells and then using modular arithmetics to extract
meaningful interpretations from sequences of 1 or 4 aminoacids.

At first, the DNA genome is read from standard input, expecting it is in the
FASTA format. DNA genomes are written in an alphabet of 4 letters: A, C, G, T,
which stand for adenine, cytosine, guanine and thymine. Those molecules are the
nitrogen-containing biological compounds that form nucleosides, which in turn
are components of nucleotides, the organic molecules, precisely monomers which form
the DNA double helyx: a polymer.

All the genome strings read from the FASTA file are merged into a big, single
one:

```ocaml
let str = String.concat "" @@ sndl @@ read_fasta stdin
```


## The First Semi-Biological Step

Then, DNA is converted into RNA with a very simple function, which replaces
the thymine symbol with the uracil symbol. In real life, this is done by an
enzime called [RNA polymerase](https://www.ncbi.nlm.nih.gov/books/NBK22085/).
RNAP locally opens the double-stranded DNA so that one strand of the exposed
nucleotides can be used as a template for the synthesis of RNA in a process
called transcription.

```ocaml
let rna_of_dna s = String.map (fun c -> match c with
  | 'T' -> 'U'
  | a -> a ) s
```

The next step is converting the RNA into a chain of aminoacids. This is what is
done inside of cells to produce proteins, the fundamental building blocks for
almost everything inside all living organisms.

From a [rosalind problem](http://rosalind.info/problems/prot/) :

> Just as nucleic acids are polymers of nucleotides, proteins are chains of
> smaller molecules called amino acids; 20 amino acids commonly appear in every
> species. Just as the primary structure of a nucleic acid is given by the order
> of its nucleotides, the primary structure of a protein is the order of its amino
> acids. Some proteins are composed of several subchains called polypeptides,
> while others are formed of a single polypeptide;


Protein synthesis and folding are **very complicated topics**.
Organelles inside of cells called ribosomes take chains of messenger RNA (mRNA)
and a helping structure called transfer RNA, and examine the mRNA in pieces of 3
nucleotides (symbols) at a time, called *codons*. Since RNA is an "*alphabet*"
of 4 symbols, there are 64 = 4^3 possible strings of length 3. Since there are
20 aminoacids, multiple codons can encode the same aminoacid. The aminoacid
corresponding to the currently examined codon of mRNA is the bond to the
growing peptide chain.

Figure: The structure of the human haemoglobin protein.
![Human Haemoglobin](/assets/images/haemoglobin.png)

The same is done in `dna2music` to convert RNA to a sequence of aminoacids.
There is a fundamental difference though: in biological cells, translation must
start with the aminoacid methionine and ends when a stop codon is found (encoded
as the character '0' below). The stop codon corresponds to no aminoacid, but
encodes a release factor: a protein that stops the translation and releases the
peptide from the ribosome. This means that translation can start at any given
part of the genome.

In `dna2music` instead, to produce a single track of music, the start and stop
codons are ignored and the latter is treated as an additional imaginary
aminoacid; the initial RNA string is trimmed to a length multiple of 3, to make
sure that there are only valid codons. This biological heresy is to make sure
that the resulting string is a single contiguous string of 21 aminoacids, 20
existing in reality and a "fictionary" one, corresponding to stop codons.

Here is the aminoacid conversion table:

```ocaml
let encode_codon_protein codon =
  if String.length codon <> 3 then
    failwith @@ codon ^ " is not a valid codon"
  else match codon with
  | "AAA" -> 'K' | "AAC" -> 'N' | "AAG" -> 'K' | "AAU" -> 'N'
  | "ACA" -> 'T' | "ACC" -> 'T' | "ACG" -> 'T' | "ACU" -> 'T'
  | "AGA" -> 'R' | "AGC" -> 'S' | "AGG" -> 'R' | "AGU" -> 'S'
  | "AUA" -> 'I' | "AUC" -> 'I' | "AUG" -> 'M' | "AUU" -> 'I'
  | "CAA" -> 'Q' | "CAC" -> 'H' | "CAG" -> 'Q' | "CAU" -> 'H'
  | "CCA" -> 'P' | "CCC" -> 'P' | "CCG" -> 'P' | "CCU" -> 'P'
  | "CGA" -> 'R' | "CGC" -> 'R' | "CGG" -> 'R' | "CGU" -> 'R'
  | "CUA" -> 'L' | "CUC" -> 'L' | "CUG" -> 'L' | "CUU" -> 'L'
  | "GAA" -> 'E' | "GAC" -> 'D' | "GAG" -> 'E' | "GAU" -> 'D'
  | "GCA" -> 'A' | "GCC" -> 'A' | "GCG" -> 'A' | "GCU" -> 'A'
  | "GGA" -> 'G' | "GGC" -> 'G' | "GGG" -> 'G' | "GGU" -> 'G'
  | "GUA" -> 'V' | "GUC" -> 'V' | "GUG" -> 'V' | "GUU" -> 'V'
  | "UAC" -> 'Y' | "UAU" -> 'Y' | "UCA" -> 'S' | "UCC" -> 'S'
  | "UCG" -> 'S' | "UCU" -> 'S' | "UGC" -> 'C' | "UGG" -> 'W'
  | "UGU" -> 'C' | "UUA" -> 'L' | "UUC" -> 'F' | "UUG" -> 'L'
  | "UUU" -> 'F' | "UAG" -> '0' | "UGA" -> '0' | "UAA" -> '0'
  | _ -> failwith "invalid codon" ;;
```

## Now Comes the Music Making!

This resulting aminoacid sequence is now a large string of an alphabet composed
of 21 symbols, it's enough to turn it into music! The symbol characters are
converted to numbers from 0 to 20, so that the string is converted to a list of
numbers. Modular arithmetics is used to restrict these numbers in smaller
ranges. Notes in the chromatic scale go from 0 to 11, while notes in a major or
minor scale go from 0 to 6. For example, notes in C Major scale, `C D E F G A
B`, can be mapped to numbers from 0 to 6. The same principle applies to all the
major or minor scales.

The first aminoacid in the sequence corresponds to the number of notes that will
be played in the current bar. It is equal to the aminoacid code number modulo 16, plus
one. This means that it can range from 1 to 16. Let's call this number `n`.

`n` following notes are read from the aminoacid sequence, if there are enough
remaning aminoacids to compose them. After the notes are read, the conversion
goes on to the next bar and reads another aminoacid that encodes again the
number of notes `n` that will make the following bar. This mechanism makes sure
that genomes of any length will always produce valid MIDI files that are not
empty or cluttered with too many notes played altogether.

Notes are created by reading 4 aminoacids at a time. The first one encodes the
location, or the delay in 16th notes from the start of the current bar. This is
when the note will start playing, and is converted by multiplying 60 by the
aminoacid code modulo 16: `(num mod 16) * 60`. In MIDI format a bar is 960
ticks, so a sixteenth note is 60 ticks long.

The second aminoacid in a note sequence encodes the duration of the note,
which is read in the exact same way but excluding notes of length 0: `((num mod 16) + 1) * 60`.
The third aminoacid in the quartet encodes the octave: `num mod 7`,
while the fourth and last aminoacid making a note sequence finally
encodes the note. This is done in a slightly more sophisticated way.

```ocaml
if scale >= 0 then
    if minor then
        autoscale_minor scale (note_in_scale_of_int note)
    else
        autoscale_minor scale (note_in_scale_of_int note)
    else note_of_int note
```

If a scale is passed as a command line argument to the program, the fourth
aminoacid in the sequence encodes a note from 0 to 6, or `num mod 7`. The
resulting note is then mapped automatically into a scale by the
`autoscale_minor` or `autoscale_major` functions, which return only the
chromatic note numbers from 0 to 11 in key with the scale passed as an argument.
If automatical mapping to a scale is disabled, the aminoacid
just encodes a note number from 0 to 11 in the chromatic scale.
The latter case will obviously not sound musical at all!


Here's a snippet of the text file resulting from SARS-Cov-2
genome-music conversion.
```
N 1920 4 6 100 840 1
N 3120 5 8 100 60 1
N 3720 0 6 100 900 1
N 3960 2 6 100 600 1
N 5640 5 14 100 360 1
N 5340 6 14 100 480 1
N 4800 0 8 100 960 1
N 5040 2 16 100 900 1
N 5340 1 8 100 180 1
N 5640 4 8 100 960 1
N 5640 4 6 100 900 1
N 5700 4 9 100 60 1
N 4800 1 11 100 600 1
N 5160 0 13 100 840 1
N 5820 3 8 100 960 1
N 5760 2 8 100 960 1
N 5820 5 16 100 240 1
N 5760 7 6 100 360 1
N 5760 6 16 100 900 1
N 6660 6 8 100 120 1
```
After printing out the whole sequence of notes, the output can
be finally redirected into a text file and converted in format MIDI
with the tool `txt2mid`, which reads exactly that format.
This is how note lines are printed in `dna2music`:




## What If I Want to Make a Song About Another Virus?

If you want to use this buggy tool, you can download the source code from my
[GitHub profile](https://github.com/0x0f0f0f/dna2music).
You can also, just as an example, download the FASTA genome of
Cytomegalovirus (Human herpesvirus 5 strain AD169) [here](https://www.ncbi.nlm.nih.gov/nuccore/BK000394.5?report=fasta).

### Building

The project only has two dependencies: `g++` and `ocaml` >= 4.03.0. You need to
build `txt2mid` first:

```bash
g++ txt2mid.cpp -o txt2mid
```

### Usage

You can download genomes in FASTA format from the National Institutes of
Health's [GenBank](https://www.ncbi.nlm.nih.gov/genbank/) database,
or from the [UCSC Genome Browser](https://genome.ucsc.edu/).
After obtaining a FASTA file, you can pipe it into `dna2music` and
redirect the output to a text file and then convert the text file to MIDI:

```bash
cat /path/to/file.fasta | ocaml dna2music.ml > file.txt
./txt2mid file.txt
# this will automatically create the MIDI file
```

`dna2music.ml` accepts two additional arguments regarding automatically mapping
the notes to a certain key, to make the generated notes sound more musical
altogether. If no additional argument is supplied key mapping will be skipped.

The first additional argument is the a string containing the key (note) in which
the music will be composed, for example `C` or `E` are valid keys. To use sharp
or flat key use the plus and minus symbols, for example `C+` or `A-`.

The second additional argument is if the scale should be minor or not: `true` is
minor and `false` is major. You can omit this argument to use the major scale.
Other scales are not implemented.
Have fun and stay at home during the lockdown!