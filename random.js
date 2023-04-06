
/// wat2wasm pcg_prng.wat --enable-memory64 -o pcg_prng.wasm

let seed, biased, unbiased;

WebAssembly.instantiateStreaming(fetch("pcg_prng.wasm")).then(({ instance }) => {
	seed = instance.exports.pcg32_srandom;
	biased = instance.exports.pcg32_random_biased;
	unbiased = instance.exports.pcg32_random_unbiased;
	console.log("WebAssembly loaded");
	seed(BigInt(Date.now()), BigInt(Date.now()));
	loop();
});
