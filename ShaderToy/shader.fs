# ifdef GL_ES
precision highp float;
# endif

uniform vec3      iResolution;     // viewport resolution (in pixels)
uniform float     iGlobalTime;     // shader playback time (in seconds)
//uniform float     iChannelTime[4]; // channel playback time (in seconds)
uniform vec4      iMouse;          // mouse pixel coords. xy: current (if MLB down), zw: click
//uniform sampler2D iChannel[4];
//uniform vec4      iDate;           // (year, month, day, time in seconds)



//shader from https://www.shadertoy.com/view/ldsGRH

float textureRND2D(vec2 uv)
{
	vec2 f = fract(uv);
	f = f*f*(3.0-2.0*f);
	uv = floor(uv);
	vec4 r = vec4(uv.x+uv.y*1e3) + vec4(0., 1., 1e3, 1e3+1.);
	r = fract(sin(r*1e-3)*1e5);
	return mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
}

void main( void )
{
	vec2 p = gl_FragCoord.xy/iResolution.xy;
	float c0 = step(textureRND2D(p*vec2(8.,.5)+vec2(100.+iGlobalTime*.2,0.))*.5, p.y-.1);
	float c1 = step(textureRND2D(p*vec2(80.,.5)+vec2(iGlobalTime*2.,iGlobalTime))*.02, p.y-.3);
	gl_FragColor = vec4(mix(vec3(.8,.6,.2)*p.y,mix(vec3(.7,.8,1.2)*p.y, vec3(p.y), c1), c0),1.0);
}