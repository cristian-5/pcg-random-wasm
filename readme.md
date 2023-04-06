
## pcg-random-wasm

🎲 Web Assembly PCG random number generator http://www.pcg-random.org.\
💗 **Handwritten**, **commented** port based on *Ph.D. Melissa E. O'Neill*'s work.

> PCG is a family of simple fast space-efficient statistically good algorithms for random number generation. Unlike many general-purpose RNGs, they are also hard to predict.

This project comes with a `p5.js` sketch to demonstrate uniform distribuition.

### API usage:

``` js
WebAssembly.instantiateStreaming(fetch("pcg_prng.wasm")).then(({ instance }) => {
	const seed = instance.exports.pcg32_srandom;
	const biased = instance.exports.pcg32_random_biased;
	const unbiased = instance.exports.pcg32_random_unbiased;
	seed(BigInt(Date.now()), BigInt(Date.now()));
	console.log(biased(20, 30), unbiased(20, 30));
});
```
