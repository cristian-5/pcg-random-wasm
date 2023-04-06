
const WIDTH = 800;
const HEIGHT = 600;

let min = 100, max = 600;
let range = max - min;
let w = WIDTH / range; // width of each bar

function setup() {
	createCanvas(800, 600);
	background(192);
	frameRate(1);
}

function draw() {
	let d = Array(max - min).fill(0);
	fill(20, 20, 120);
	noStroke();
	const rounds = range * 100;
	for (let x = 0; x < rounds; x++)
		d[biased(min, max) - min]++;
	for (let x = 0; x < range; x++) {
		let y = map(d[x], 0, range, 0, height);
		rect(x * w, height - y, w, y);
	}
}
