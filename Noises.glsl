/*
SOURCES:
- https://mrl.nyu.edu/~perlin/noise/
- https://www.ronja-tutorials.com/2018/09/15/perlin-noise.html
- https://gpfault.net/posts/perlin-noise.txt.html
- https://rmarcus.info/blog/2018/03/04/perlin-noise.html
- http://flafla2.github.io/2014/08/09/perlinnoise.html
- https://thebookofshaders.com/11/
- https://www.shadertoy.com/view/4dS3Wd

PERLIN NOISE USAGES:
- https://www.shadertoy.com/view/XlyXRW
- https://www.shadertoy.com/view/XlGSzW?
- https://www.shadertoy.com/view/4sc3z2
- https://www.shadertoy.com/view/lllBDM
*/

//Noise dimensions -> choose one
//#define NOISE1D
//#define NOISE2D
#define NOISE3D

//Noise hash method -> choose one
//#define HASH(value, seed) simpleHash(value)
//#define HASH(value, seed) betterHash(value)
#define HASH seedHash

//Noise method -> choose one
//#define NOISE(value, cellSize, seed) noise(value, seed)
//#define NOISE cell
#define NOISE interpolated

//For presenting gradient noise we move it from <-1;1> to <0;1> range
//#define NOISE(value, cellSize, seed) 0.5 + gradient(value, cellSize, seed) / 2.0

//Interpolation sampler -> choose one
//#define SAMPLER cell
//When sampling gradient noise we move it up to have it between <0;1> range
#define SAMPLER(value, cellSize, dir, seed) 0.5 + gradient(value, cellSize, dir, seed)

//Interpolation method -> choose one
//LINEAR
//#define INTERPOLATE(x) x
//EASE IN
//#define INTERPOLATE(x) x * x
//EASE OUT
//#define INTERPOLATE(x) x * (2.0 - x)
//EASE IN-OUT => HERMITE
//#define INTERPOLATE(x) mix(x * x, x * (2.0 - x), x)
//HERMITE (SMOOTHSTEP)
//#define INTERPOLATE(x) x * x * (3.0 - 2.0 * x)
//KEN PERLIN
#define INTERPOLATE(x) x * x * x * (x * (x * 6.0 - 15.0) + 10.0);

//Random generator data
#define SEED 26.93
#define CELL_SIZE 0.1

//Animation data
#define ANIM_SPEED 60.0
#define CAM_SPEED .4
#define LIGHT_DIR normalize(vec3(-sin(iTime * CAM_SPEED), -1.0, -0.8))

//Octaves data
#define OCTAVES 4
#define PERSISTENCE 0.5

//Misc data
//#define LINES
#define THRESHOLDNOISE 1.6

//This only works in 3D
#define IMPROVEDPERLIN

//VALUE NOISE
float simpleHash(float value) { return fract(value * 23638.4851); }
//betterHash => fract(sin(value) * bigValue);
float betterHash(float value) { return simpleHash(sin(value)); }
//seedHash => fract(sin(value + seed) * bigValue);
float seedHash(float value, float seed) { return betterHash(value + seed + 52.342); }

float noise(float value, float seed) { return HASH(value, seed); }
float noise(vec2 value, float seed) { return HASH(dot(value, vec2(25.123, 23.4124)), seed); }
float noise(vec3 value, float seed) { return HASH(dot(value, vec3(42.154, 81.1543, 12.45321)), seed); }

float noise(vec2 value, float seed, vec2 dir) { return HASH(dot(value, dir), seed); }
float noise(vec3 value, float seed, vec3 dir) { return HASH(dot(value, dir), seed); }

vec2 noise2D(vec2 value, float seed) { return vec2(noise(value, seed), noise(value, seed, vec2(65.481, 48.872))); }
vec3 noise3D(vec3 value, float seed) { return vec3(noise(value, seed), noise(value, seed, vec3(54.782, 78.1241, 54.128)), noise(value, seed, vec3(57.14, 97.423, 15.751))); }

//CELL NOISE
float cell(float value, float cellSize, float dir, float seed) { return HASH(floor(value / cellSize) + dir, seed); }
float cell(vec2 value, float cellSize, vec2 dir, float seed) { return noise(floor(value / cellSize) + dir, seed); }
float cell(vec3 value, float cellSize, vec3 dir, float seed) { return noise(floor(value / cellSize) + dir, seed); }

float cell(float value, float cellSize, float seed) { return cell(value, cellSize, .0, seed); }
float cell(vec2 value, float cellSize, float seed) { return cell(value, cellSize, vec2(.0), seed); }
float cell(vec3 value, float cellSize, float seed) { return cell(value, cellSize, vec3(.0), seed); }

//GRADIENT NOISE
float gradient(float value, float cellSize, float dir, float seed) { 
    float cellValue = value / cellSize + dir;
    return (HASH(floor(cellValue), seed) * 2.0 - 1.0) * (fract(cellValue) - dir);
}
float gradient(vec2 value, float cellSize, vec2 dir, float seed) { 
    vec2 cellValue = value / cellSize + dir;
    vec2 grad = noise2D(floor(cellValue), seed) * 2.0 - 1.0;
    return dot(vec2(grad.x, grad.y), fract(cellValue) - dir);
}
float gradient(vec3 value, float cellSize, vec3 dir, float seed) {
    vec3 cellValue = value / cellSize + dir;
    vec3 grad = noise3D(floor(cellValue), seed) * 2.0 - 1.0;
    return dot(vec3(grad.x, grad.y, grad.z), fract(cellValue) - dir);
}

float gradient(float value, float cellSize, float seed) { return gradient(value, cellSize, .0, seed); }
float gradient(vec2 value, float cellSize, float seed) { return gradient(value, cellSize, vec2(.0), seed); }
float gradient(vec3 value, float cellSize, float seed) { return gradient(value, cellSize, vec3(.0), seed); }

// Source: http://riven8192.blogspot.com/2010/08/calculate-perlinnoise-twice-as-fast.html
float grad(int hash, vec3 pos)
{
    switch(hash & 0xF)
    {
        case 0x0: return  pos.x + pos.y;
        case 0x1: return -pos.x + pos.y;
        case 0x2: return  pos.x - pos.y;
        case 0x3: return -pos.x - pos.y;
        case 0x4: return  pos.x + pos.z;
        case 0x5: return -pos.x + pos.z;
        case 0x6: return  pos.x - pos.z;
        case 0x7: return -pos.x - pos.z;
        case 0x8: return  pos.y + pos.z;
        case 0x9: return -pos.y + pos.z;
        case 0xA: return  pos.y - pos.z;
        case 0xB: return -pos.y - pos.z;
        case 0xC: return  pos.y + pos.x;
        case 0xD: return -pos.y + pos.z;
        case 0xE: return  pos.y - pos.x;
        case 0xF: return -pos.y - pos.z;
        default: return .0; // never happens
    }
}

//INTERPOLATED NOISE
float interpolated(float value, float cellSize, float seed) 
{
    //Current and next value to interpolate
    float v1 = SAMPLER(value, cellSize, .0, seed);
    float v2 = SAMPLER(value, cellSize, 1.0, seed);
    float interpolator = INTERPOLATE(fract(value / cellSize));
    return mix(v1, v2, interpolator);
}

float interpolated(vec2 value, float cellSize, float seed)
{
    //4 corners to interpolate
    float c1 = SAMPLER(value, cellSize, vec2(.0), seed);
    float c2 = SAMPLER(value, cellSize, vec2(1.0, .0), seed);
    float c3 = SAMPLER(value, cellSize, vec2(.0, 1.0), seed);
    float c4 = SAMPLER(value, cellSize, vec2(1.0, 1.0), seed);

    vec2 cellValue = fract(value / cellSize);
    float interpolatorX = INTERPOLATE(cellValue.x);
    float interpolatorY = INTERPOLATE(cellValue.y);

    float v1 = mix(c1, c2, interpolatorX);
    float v2 = mix(c3, c4, interpolatorX);

    return mix(v1, v2, interpolatorY);
}

float interpolated(vec3 value, float cellSize, float seed)
{
    //8 corners to interpolate
    vec3 c1dir = vec3(.0);
    vec3 c2dir = vec3(1.0, .0, .0);
    vec3 c3dir = vec3(.0, 1.0, .0);
    vec3 c4dir = vec3(1.0, 1.0, .0);
    vec3 c5dir = vec3(.0, .0, 1.0);
    vec3 c6dir = vec3(1.0, .0, 1.0);
    vec3 c7dir = vec3(.0, 1.0, 1.0);
    vec3 c8dir = vec3(1.0, 1.0, 1.0);

    #ifdef IMPROVEDPERLIN
    float c1 = cell(value, cellSize, c1dir, seed);
    float c2 = cell(value, cellSize, c2dir, seed);
    float c3 = cell(value, cellSize, c3dir, seed);
    float c4 = cell(value, cellSize, c4dir, seed);
    float c5 = cell(value, cellSize, c5dir, seed);
    float c6 = cell(value, cellSize, c6dir, seed);
    float c7 = cell(value, cellSize, c7dir, seed);
    float c8 = cell(value, cellSize, c8dir, seed);
    #else
    float c1 = SAMPLER(value, cellSize, c1dir, seed);
    float c2 = SAMPLER(value, cellSize, c2dir, seed);
    float c3 = SAMPLER(value, cellSize, c3dir, seed);
    float c4 = SAMPLER(value, cellSize, c4dir, seed);
    float c5 = SAMPLER(value, cellSize, c5dir, seed);
    float c6 = SAMPLER(value, cellSize, c6dir, seed);
    float c7 = SAMPLER(value, cellSize, c7dir, seed);
    float c8 = SAMPLER(value, cellSize, c8dir, seed);
    #endif
    
    vec3 cellValue = fract(value / cellSize);
    float interpolatorX = INTERPOLATE(cellValue.x);
    float interpolatorY = INTERPOLATE(cellValue.y);
    float interpolatorZ = INTERPOLATE(cellValue.z);

    #ifdef IMPROVEDPERLIN
    float vx1 = mix(grad(int(c1 * 255.0), cellValue - c1dir), grad(int(c2 * 255.0), cellValue - c2dir), interpolatorX);
    float vx2 = mix(grad(int(c3 * 255.0), cellValue - c3dir), grad(int(c4 * 255.0), cellValue - c4dir), interpolatorX);
    float vx3 = mix(grad(int(c5 * 255.0), cellValue - c5dir), grad(int(c6 * 255.0), cellValue - c6dir), interpolatorX);
    float vx4 = mix(grad(int(c7 * 255.0), cellValue - c7dir), grad(int(c8 * 255.0), cellValue - c8dir), interpolatorX);
    #else
    float vx1 = mix(c1, c2, interpolatorX);
    float vx2 = mix(c3, c4, interpolatorX);
    float vx3 = mix(c5, c6, interpolatorX);
    float vx4 = mix(c7, c8, interpolatorX);
    #endif
    
    float vy1 = mix(vx1, vx2, interpolatorY);
    float vy2 = mix(vx3, vx4, interpolatorY);

    float result = mix(vy1, vy2, interpolatorZ);

    #ifdef IMPROVEDPERLIN
    return (result + 1.0) / 2.0;
    #else
    return result;
    #endif
}

//---------------------------------------------
//Sphere drawing
const float pi = 3.1415927410125732421875;
const float inf = 1.0 / 0.0;
float negToInf(float x) { return (x >= .0) ? x : inf; }

float intersectSphere(vec3 centre, float radius, vec3 rayPos, vec3 rayDir)
{
    vec3 lookVec = centre - rayPos;
    float lookProj = dot(lookVec, rayDir);
    float lookDis = dot(lookVec, lookVec) - radius * radius;
    float surfDisSqr = (lookProj * lookProj - lookDis);
    if (surfDisSqr <= .0) return inf;
    float surfDis = sqrt(surfDisSqr);

    return min(negToInf(lookProj - surfDis), negToInf(lookProj + surfDis));
}

float drawSphere(vec2 uv, float frequency, float amplitude)
{
    const float fov = 25.0 * pi / 180.0;
    vec3 viewPos = vec3(sin(iTime * CAM_SPEED), 0, 10.0);
    vec3 viewDir = normalize(vec3(uv.xy - iResolution.xy / vec2(2.0, 2.0), 
                        iResolution.y / -tan(fov)));
    float surfDis = intersectSphere(vec3(0, 0.1, 0), 1.0, viewPos, viewDir);
    
    if (surfDis < inf)
    {
        vec3 surfVec = viewPos + viewDir * surfDis;

        //3D NOISES
        float value = amplitude * NOISE(frequency * surfVec + iTime * ANIM_SPEED * 0.004, CELL_SIZE, SEED);

        vec3 surfNormal = normalize(surfVec);

        float rimLight = saturate(0.4 + dot(-surfNormal, viewDir));
        float light = max(dot(-surfNormal, LIGHT_DIR), .0) + 0.1;
        return saturate(value * light * rimLight);
    }
    else
    {
        surfDis = intersectSphere(vec3(0, -2000.0, 0), 1999.1, viewPos, viewDir);
        if (surfDis < inf)
        {
            vec3 surfVec = viewPos + viewDir * surfDis;
            float value = amplitude * NOISE(frequency * surfVec + iTime * ANIM_SPEED * 0.001, CELL_SIZE, SEED);
            float shadow = saturate(length(surfVec.xz) * 0.6);
            return saturate(value * (0.6 - length(surfDis) * 0.02) * shadow * shadow);
        }
        return 0.1 * amplitude;
    }
}
//---------------------------------------------

float standardNoise(vec2 uv)
{
    float val;

    //1D NOISES
    #ifdef NOISE1D
    float noise1D = NOISE(uv.x + floor(iTime * ANIM_SPEED) / iResolution.x, CELL_SIZE, SEED);
    //val = saturate((noise1D - uv.y) / 0.001);
    val = (abs(noise1D - uv.y) < 0.02 ? 1.0 : .0);
    #endif

    //2D NOISES
    #ifdef NOISE2D
    val = NOISE(uv.xy + vec2(floor(iTime * ANIM_SPEED)) / iResolution.x, CELL_SIZE, SEED);
    #endif

    //DRAWING SPHERE
    #ifdef NOISE3D
    val = drawSphere(gl_FragCoord.xy, 1.0, 1.0);
    #endif

    return val;
}

float octaveNoise(vec2 uv)
{
    float val = .0;
    float frequency = 1.0;
    float amplitude = 1.0;
    float maxValue = .0;

    //OCTAVES
    for (int i = 0; i < OCTAVES; ++i)
    {
        //1D NOISES
        #ifdef NOISE1D
        val += amplitude * NOISE(uv.x * frequency + floor(iTime * ANIM_SPEED) / iResolution.x, CELL_SIZE, SEED);
        //2D NOISES
        #elif defined(NOISE2D)
        val += amplitude * NOISE(uv.xy * frequency + vec2(floor(iTime * ANIM_SPEED)) / iResolution.x, CELL_SIZE, SEED);
        //DRAWING SPHERE
        #elif defined(NOISE3D)
        val += drawSphere(gl_FragCoord.xy, frequency, amplitude);
        #endif

        maxValue += amplitude;
        amplitude *= PERSISTENCE;
        frequency *= 2.0;
    }

    //Normalize the value to range <0;1>
    #ifdef THRESHOLDNOISE
    float threshold = maxValue - THRESHOLDNOISE;
    val = (val > threshold) ? smoothstep(.0, 1.0, val - threshold) : .0;
    #else
    val = val / maxValue;
    #endif

    #ifdef NOISE1D
    val = (abs(val - uv.y) < 0.02 ? 1.0 : .0);
    #endif

    return saturate(val);
}

void main()
{
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);

    float val;
    val = OCTAVES == 1 ? standardNoise(uv) : octaveNoise(uv);

    #ifdef LINES
    val = fract(val * 7.0);
    float deltaNoise = fwidth(val);
    float line = smoothstep(1.0 - deltaNoise, 1.0, val);
    val = line + smoothstep(deltaNoise, .0, val);
    #endif

    #ifdef THRESHOLDNOISE
    val += 0.1;
    vec4 col = vec4(val / 4.0, val / 2.0, val, 1.0);
    #else
    vec4 col = vec4(val, val, val, 1.0);
    #endif
    gl_FragColor = col;
}