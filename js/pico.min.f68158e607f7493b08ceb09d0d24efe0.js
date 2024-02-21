console.log(`
                                                            
8 888888888o    8 8888     ,o888888o.        ,o888888o.     
8 8888    \`88.  8 8888    8888     \`88.   . 8888     \`88.   
8 8888     \`88  8 8888 ,8 8888       \`8. ,8 8888       \`8b  
8 8888     ,88  8 8888 88 8888           88 8888        \`8b 
8 8888.   ,88'  8 8888 88 8888           88 8888         88 
8 888888888P'   8 8888 88 8888           88 8888         88 
8 8888          8 8888 88 8888           88 8888        ,8P 
8 8888          8 8888 \`8 8888       .8' \`8 8888       ,8P  
8 8888          8 8888    8888     ,88'   \` 8888     ,88'   
8 8888          8 8888     \`8888888P'        \`8888888P'     

`);
;
if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
  document.documentElement.classList.add('dark')
} else {
  document.documentElement.classList.remove('dark')
}
