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
	
	postBlend_fs4x.glsl
	Blending layers, composition.
*/

// Modified by Jonathan DeLeon

#version 450

// ****DONE:
//	-> declare texture coordinate varying and set of input textures
//	-> implement some sort of blending algorithm that highlights bright areas
//		(hint: research some Photoshop blend modes)

layout (location = 0) out vec4 rtFragColor;
in vec4 vTexcoord_atlas;
uniform sampler2D uImage00, uImage01, uImage02, uImage03;

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE PURPLE
	//rtFragColor = vec4(0.5, 0.0, 1.0, 1.0);

	// All previous post processing passes

	float bloomScale = 0.7;

	vec3 color0 = texture(uImage00, vTexcoord_atlas.xy).rgb;
	vec3 color1 = texture(uImage01, vTexcoord_atlas.xy).rgb;
	vec3 color2 = texture(uImage02, vTexcoord_atlas.xy).rgb;
	vec3 color3 = texture(uImage03, vTexcoord_atlas.xy).rgb;

	vec3 bloom = color1 + color2 + color3; // blend passes and add to original pass, scaled

	rtFragColor = vec4(color0 + bloom * bloomScale, 1.0);
}
