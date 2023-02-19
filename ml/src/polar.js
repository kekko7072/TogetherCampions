let velocity = [5, 6, 7]; // velocità della barca in metri al secondo
let directionAngle = 30; // angolo di direzione della barca in gradi
let x = [1, 2, 3]; // coordinate cartesiane della barca
let acceleration = [0.5, 0.7, 0.9]; // accelerazione lungo i tre assi in metri al secondo^2

// Calcolare la velocità apparente
let apparentVelocity = velocity * Math.sin(directionAngle);

// Calcolare la direzione del vento
let windDirection = Math.atan2(apparentVelocity, velocity);

// Calcolare la polare
let polar = [];
for (let i = 0; i < velocity.length; i++) {
  polar.push({
    windDirection: windDirection[i],
    apparentVelocity: apparentVelocity[i],
    x: x[i],
    acceleration: acceleration[i],
  });
}

console.log(polar);
