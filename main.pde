var clock = 489;
var days = 0;
var det = 0;
var seed = 0;
var plants = [];
var creatures = [];

var nullvec;
var tst;

function display_terrain(night){
    if(night === 0){
        background(219, 250, 175);
    }
    else {
        background(22, 69, 5);
    }
    if(night === 0){
        stroke(89, 58, 7);
    }
    else {
        stroke(166, 113, 7);
    }
    strokeWeight(1);
    line(30, 30, 30, height-30);
    line(30, 30, width-30, 30);
    line(width-30, height-30, width-30, 30);
    line(width-30, height-30, 30, height-30);
    noStroke();
}

function gen_plants(c){
    if(c === 0){
        plants = [];
    }
    else {
        var d = floor(random(90, 121));
        for(var i = 0; i < d; i++){
            var px = random(30, width-30);
            var py = random(30, height-30);
            plants.push([px, py]);
        }
    }
}

function display_plants(){
    for(var i = 0; i < plants.length; i++){
        fill(0, 128, 0);
        noStroke();
        ellipse(plants[i][0], plants[i][1], 10, 10);
    }
}

function Creature(x, y, spd, sse, end, sz){
    this.pos = createVector(x, y);
    this.angle = 0;
    
    this.speed = spd;
    this.size = sz;
    this.sense = sse;
    this.endr = end;
    
    this.energy = 480;
    this.energyConsumption = (this.size*this.size*this.speed*this.speed/2+this.sense/1600)/(1-this.endr);
    
    this.id = seed;
    seed++;
    
    this.sleep = false;
    this.food = 0;
    this.target = nullvec;
    this.freeze = 0;
    
    this.prey = nullvec;
    this.escape = nullvec;
}

Creature.prototype.display = function(){
    push();
    translate(this.pos.x, this.pos.y);
    rotate(this.angle);
    if(this.freeze !== 0){
        fill(115, 115, 115);
        ellipse(0, 0, this.size*25, this.size*25);
    }
    fill(255*this.endr, 255*this.speed, this.sense*3);
    ellipse(0, 0, this.size*20, this.size*20);
    fill(255, 255, 255);
    ellipse(6, 4, this.size*5, this.size*5);
    ellipse(6, -4, this.size*5, this.size*5);
    pop();
}

Creature.prototype.walk = function(){
    if(this.energy === 0){
        return;
    }
    if(this.escape !== nullvec){
        if(typeof(creatures[this.escape.x]) === 'object' && creatures[this.escape.x].id === this.escape.y && p5.Vector.sub(this.pos, creatures[this.escape.x].pos).mag() < this.sense/2 && !creatures[this.escape.x].sleep){
            this.angle = p5.Vector.sub(this.pos, creatures[this.escape.x].pos).heading();
        }
        else {
            this.escape = nullvec;
        }
    }
    else if(typeof(creatures[this.prey.x]) === 'object' && this.prey !== nullvec && this.food !== 2 && p5.Vector.sub(this.pos, creatures[this.escape.x].pos).mag() < this.sense){
        if(creatures[this.prey.x].id === this.prey.y){
            this.angle = p5.Vector.sub(creatures[this.prey.x].pos, this.pos).heading();
        }
        else {
            this.prey = nullvec;
        }
    }
    else if(this.target !== nullvec && this.food !== 2){
        this.angle = p5.Vector.sub(this.target, this.pos).heading();
    }   
    else {
        var d = floor(random(2));
        if(d === 0){
            this.angle+=5;
        }
        else {
            this.angle-=5;
        }
        if(this.angle < 0){
            this.angle = 360+this.angle;
        }
        if(this.angle > 360){
            this.angle = this.angle-360;
        }
        if(this.pos.x < this.sense && random(1, 20) < 5*this.speed){
            this.angle = 0;
        }
        if(this.pos.y < this.sense && random(1, 20) < 2){
            this.angle = 90;
        }
        if(this.pos.x > width-this.sense && random(1, 20) < 2){
            this.angle = 180;
        }
        if(this.pos.y > height-this.sense && random(1, 20) < 2){
            this.angle = 270;
        }
    }
    this.pos.x += this.speed*cos(this.angle);
    this.pos.y += this.speed*sin(this.angle);
}

Creature.prototype.ret = function(){
    if(clock === 500){
        this.sleep = false;
    }
    var d = min(min(abs(this.pos.x-30),abs(width-30-this.pos.x)),min(abs(this.pos.y-30),abs(height-30-this.pos.y)));
    var eq = d/this.speed*this.energyConsumption;
    if(2100-clock < d/this.speed+20 || eq > this.energy-5){
        this.sleep = true;
    }
    if(this.sleep){
        if(abs(this.pos.x-30) < this.speed){
            this.pos.x = 30;
            this.angle = 0;
        }
        else if(abs(this.pos.y-30) < this.speed){
            this.pos.y = 30;
            this.angle = 90;
        }
        else if(abs(width-30-this.pos.x) < this.speed){
            this.pos.x = width-30;
            this.angle = 180;
        }
        else if(abs(height-30-this.pos.y) < this.speed){
            this.pos.y = height-30;
            this.angle = 270;
        }
        else {
            if(d === abs(this.pos.x-30)){
                if(this.pos.x > 30){
                    this.angle = 180;
                }
                else {
                    this.angle = 0;
                }
            }
            if(d === abs(this.pos.y-30)){
                if(this.pos.y > 30){
                    this.angle = 270;
                }
                else {
                    this.angle = 90;
                }
            }
            if(d === abs(width-30-this.pos.x)){
                if(this.pos.x < width-30){
                    this.angle = 0;
                }
                else {
                    this.angle = 180;
                }
            }
            if(d === abs(height-30-this.pos.y)){
                if(this.pos.y < height-30){
                    this.angle = 90;
                }
                else {
                    this.angle = 270;
                }
            }
            if(!this.sleep){
                this.energy -= this.energyConsumption;
            }
            if(this.energy > 0){
                this.pos.x += this.speed*cos(this.angle);
                this.pos.y += this.speed*sin(this.angle);
            }
        }
    }
}

Creature.prototype.forage = function(){
    for(var i = creatures.length-1; i >= 0; i--){
        if(creatures[i].size > 1.25*this.size && p5.Vector.sub(this.pos, creatures[i].pos).mag() < this.sense/2 && !creatures[i].sleep){
            this.escape = createVector(i, creatures[i].id);
        }
    }
    if(this.food >= 2){
        return;
    }
    if(this.food === 1){
        for(var i = creatures.length-1; i >= 0; i--){
            if(creatures[i].size < 0.8*this.size && this.target === nullvec && this.prey === nullvec && clock >= 800 && clock <= 1900 && p5.Vector.sub(this.pos, creatures[i].pos).mag() < this.sense){
                this.prey = createVector(i, creatures[i].id);
            }
            if(p5.Vector.sub(this.pos, creatures[i].pos).mag() < 5 && creatures[i].size < 0.8*this.size){
                this.food += 2;
                creatures.splice(i, 1)
                this.prey = nullvec;
                this.freeze = 20;
            }
        }
        var exist = false;
        for(var i = plants.length-1; i >= 0; i--){
            var v = createVector(plants[i][0], plants[i][1]);
            if(this.target === nullvec && p5.Vector.sub(this.pos, v).mag() < this.sense){
                this.target = v;
            }
            if(p5.Vector.sub(this.pos, v).mag() < 5){
                this.food++;
                plants.splice(i, 1);
                this.target = nullvec;
                this.freeze = 10;
            }
            if(v === this.target){
                exist = true;
            }
        }
        if(!exist){
            this.target = nullvec;
        }
    }
    if(this.food === 0){
         for(var i = creatures.length-1; i >= 0; i--){
            if(creatures[i].size < 0.8*this.size && this.target === nullvec && this.prey === nullvec && clock >= 800 && clock <= 1900 && p5.Vector.sub(this.pos, creatures[i].pos).mag() < this.sense){
                this.prey = createVector(i, creatures[i].id);
            }
            if(p5.Vector.sub(this.pos, creatures[i].pos).mag() < 5 && creatures[i].size < 0.8*this.size){
                this.food += 2;
                creatures.splice(i, 1)
                this.prey = nullvec;
                this.freeze = 20;
            }
        }
        var exist = false;
        for(var i = plants.length-1; i >= 0; i--){
            var v = createVector(plants[i][0], plants[i][1]);
            if(this.target === nullvec && p5.Vector.sub(this.pos, v).mag() < this.sense){
                this.target = v;
            }
            if(p5.Vector.sub(this.pos, v).mag() < 5){
                this.food++;
                plants.splice(i, 1);
                this.target = nullvec;
                this.freeze = 10;
            }
            if(v === this.target){
                exist = true;
            }
        }
        if(!exist){
            this.target = nullvec;
        }
    }
    
}

Creature.prototype.replicate = function(){
    var mut = floor(random(-10, 11))/100;
    var s = this.speed + mut;
    if(s < 0.2){
        s = 0.2;
    }
    if(s > 0.8){
        s = 0.8;
    }
    mut = floor(random(-2, 3));
    var sse = this.sense + mut;
    if(sse < 1){
        sse = 1;
    }
    if(sse > 80){
        sse = 80;
    }
    mut = floor(random(-10, 11))/100;
    var end = this.endr + mut;
    if(end < 0){
        end = 0;
    }
    if(end > 0.9){
        end = 0.9;
    }
    mut = floor(random(-5, 6))/100;
    var sz = this.size + mut;
    if(sz < 0.4){
        sz = 0.4;
    }
    if(sz > 2.0){
        sz = 2.0;
    }
    var c = new Creature(this.pos.x, this.pos.y, s, sse, end, sz);
    c.sleep = true;
    creatures.push(c);
}

Creature.prototype.update = function(){
    this.display();
    if(!this.sleep && this.freeze === 0){
        this.walk();
        this.forage();
    }
    if(this.freeze !== 0){
        this.freeze--;
    }
    this.ret();
}

function outside(c){
    if(c.pos.x > width || c.pos.x < 0 || c.pos.y > height || c.pos.y < 0){
        return true;
    }
    return false;
}

function setup() {
  createCanvas(900,900);
  background(0);
  fill(255);
  angleMode(DEGREES);
  nullvec = createVector(0, 0);
  tst = createVector(500, 500);
  for(var i = 0; i < 25; i++){
     creatures.push(new Creature(floor(random(300, 701)), floor(random(300, 701)), floor(random(20, 81))/100, floor(random(20, 60)), floor(random(0, 80))/100, floor(random(70, 130))/100));   
  }
}

function draw() {
    background(0, 0, 0);
    det++;
    if(det === 1){
        det = 0;
        clock++;
    }
    if(clock === 2400){
        clock = 0;
    }
    
    if(clock < 450 || clock > 2120){
        display_terrain(1);
    }
    else {
        display_terrain(0);
    }
    
    fill(255,0,0);
    text("Time:"+clock, width-57, 10);
    text("Day "+days, width-57, 20);
    text("Population:"+creatures.length, width-80, height-10);
    
    if(clock === 490){
        gen_plants(1);
    }
    if(clock === 2110){
        gen_plants(0);
    }
    display_plants();
    for(var i = creatures.length-1; i >= 0; i--){
        if(typeof(creatures[i]) === 'object'){
            creatures[i].update();
        }
        
        if(typeof(creatures[i]) === Creature && outside(creatures[i])){
            creatures.splice(i, 1);
        }
    }
    if(clock === 0){
        var a = creatures.length-1;
        for(var j = a; j >= 0; j--){
            if(typeof(creatures[j]) !== 'object'){
                continue;
            }
            if(creatures[j].food === 0){
                var r = random(0, 1);
                if(r > creatures[j].endr){
                    creatures.splice(j, 1);
                    continue;
                }
            }
            if(creatures[j].pos.x !== 30 && creatures[j].pos.y !== 30 && creatures[j].pos.x !== width-30 && creatures[j].pos.y !== height-30){
                creatures.splice(j, 1);
                continue;
            }
            if(creatures[j].food >= 2){
                creatures[j].replicate();
            }
            creatures[j].food = 0;
            creatures[j].energy = 200;
        }
        days++;
    }
}

mouseClicked = function(){
    creatures.push(new Creature(mouseX, mouseY, floor(random(20, 81))/100, floor(random(20, 60)), floor(random(0, 80))/100, floor(random(70, 130))/100)); 
}
