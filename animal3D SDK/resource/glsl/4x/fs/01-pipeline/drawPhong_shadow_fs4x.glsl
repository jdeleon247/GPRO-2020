/*
	Copyright 2011-2021 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/

// Modified by Jonathan DeLeon

#version 450

// ****TO-DO:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

// Shadow mapping credit: OpenGL SuperBible pg.649 + http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/
// Phong shader credit: OpenGL SuperBible pg.668

layout (location = 0) out vec4 rtFragColor;
layout (binding = 0) uniform sampler2D uTex_shadow;

uniform int uCount;

in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;
in vec4 vShadowCoord;

uniform sampler2D uSampler;
struct sPointLightData
{
	vec4 position;					// position in rendering target space
	vec4 worldPos;					// original position in world space
	vec4 color;						// RGB color with padding
	float radius;					// radius (distance of effect from center)
	float radiusSq;					// radius squared (if needed)
	float radiusInv;				// radius inverse (attenuation factor)
	float radiusInvSq;				// radius inverse squared (attenuation factor)
};

uniform ubLight
{
	sPointLightData uLightData[8];
};


float shininess = 128.0; // 128 as "shininess" power; OpenGL SuperBible pg.615

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	rtFragColor = vec4(1.0, 0.0, 1.0, 1.0);
	vec4 result;
	for (int i = 0; i < uCount; i++)
	{
		vec4 N = normalize(vNormal);
		vec4 L = normalize(uLightData[i].position - vPosition);
		float distance = length(L);

		vec4 viewVec = normalize(-vPosition);
		vec4 reflectionVec = reflect(-L, N);

		// Getting attenuation value
		float attenuation = distance/uLightData[i].radius * 3;
		float attenuationAlbedo = 1.0 / ((attenuation * attenuation + 1));

		// Getting diffuse value
		float diffuse = max(dot(N,L), 0.0) * attenuationAlbedo;

		// Getting specular value
		float specular = pow(max(dot(viewVec, reflectionVec), 0.0), shininess) * attenuationAlbedo; 
		result += (diffuse * uLightData[i].color * texture2D(uSampler, vTexcoord)) + (specular * uLightData[i].color * texture2D(uSampler, vTexcoord));



	}

	// Shadow mapping from http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/
	vec4 shadowCoord = vShadowCoord / vShadowCoord.w;
	vec4 shadowTex = texture(uTex_shadow, shadowCoord.xy);
		
	float bias = 0.005;

	float visibility = 1.0;
	if ( shadowTex.r <  shadowCoord.z-bias)
	{
		visibility = 0.5;
	}		
	rtFragColor = visibility * result;
}
