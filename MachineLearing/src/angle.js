const tf = require("@tensorflow/tfjs");

const data = [
  {
    latitude: 37.7749,
    longitude: -122.4194,
    windSpeed: 5,
    boatSpeed: 10,
    boatInclination: 0,
    boatHeading: 180,
    atmosphericPressure: 1013,
    humidity: 70,
    temperature: 20,
    optimalAngle: 10,
  },
  {
    latitude: 38.8951,
    longitude: -77.0367,
    windSpeed: 7,
    boatSpeed: 12,
    boatInclination: 5,
    boatHeading: 90,
    atmosphericPressure: 1015,
    humidity: 60,
    temperature: 25,
    optimalAngle: 15,
  },
  {
    latitude: 40.7128,
    longitude: -74.006,
    windSpeed: 8,
    boatSpeed: 11,
    boatInclination: -5,
    boatHeading: 270,
    atmosphericPressure: 1017,
    humidity: 65,
    temperature: 22,
    optimalAngle: 20,
  },
];

const xs = tf.tensor2d(
  data.map((item) => [
    item.latitude,
    item.longitude,
    item.windSpeed,
    item.boatSpeed,
    item.boatInclination,
    item.boatHeading,
    item.atmosphericPressure,
    item.humidity,
    item.temperature,
  ])
);
const ys = tf.tensor2d(data.map((item) => [item.optimalAngle]));

const model = tf.sequential();
model.add(tf.layers.dense({ units: 9, inputShape: [9], activation: "relu" }));
model.add(tf.layers.dense({ units: 1, activation: "linear" }));
model.compile({ loss: "meanSquaredError", optimizer: "sgd" });

async function trainModel() {
  const h = await model.fit(xs, ys, { epochs: 100 });
  console.log(h.history.loss[0]);
}

trainModel();

async function predictOptimalAngle(
  latitude,
  longitude,
  windSpeed,
  boatSpeed,
  boatInclination,
  boatHeading,
  atmosphericPressure,
  humidity,
  temperature
) {
  const xs = tf.tensor2d([
    [
      latitude,
      longitude,
      windSpeed,
      boatSpeed,
      boatInclination,
      boatHeading,
      atmosphericPressure,
      humidity,
      temperature,
    ],
  ]);
  const result = model.predict(xs);
  console.log(`Optimal angle: ${result.dataSync()[0]}`);
}

predictOptimalAngle(37.7749, -122.4194, 5, 10, 0, 180, 1013, 70, 20);
