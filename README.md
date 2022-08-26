# Convolution Bloom
 An open source convolution bloom method <br />

# What is convolution bloom?
 Most bloom implementations use a tile based approach. While fast it does not produce the most realistic results, <br />
 so I looked into other methods. The best method that I could find is called convolution bloom, and it gets the <br />
 name from the fact it uses FFTs to use a convolution kernel as the blur shape and size. <br />

# Why use this over faster bloom?
 Despite being slower it is much more flexible and can give significantly more accurate results.