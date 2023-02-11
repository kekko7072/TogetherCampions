const tf = require("@tensorflow/tfjs");

async function trainModel(xs, ys) {
  // Creare un modello vuoto
  const model = tf.sequential();

  // Aggiungere una sola unità densa come layer di output
  model.add(tf.layers.dense({ units: 1, inputShape: [1] }));

  // Compilare il modello con un ottimizzatore e una funzione di perdita
  model.compile({ optimizer: "sgd", loss: "meanSquaredError" });

  // Addestrare il modello sui dati forniti
  await model.fit(xs, ys, { epochs: 100 });

  return model;
}

async function run() {
  // Dati di esempio per l'addestramento del modello
  const xs = tf.tensor2d([1, 2, 3, 4], [4, 1]);
  const ys = tf.tensor2d([1, 3, 5, 7], [4, 1]);

  // Addestrare il modello
  const model = await trainModel(xs, ys);

  // Fare una previsione utilizzando il modello addestrato
  const output = model.predict(tf.tensor2d([5], [1, 1]));
  console.log(output.dataSync()[0]);
}

run();
