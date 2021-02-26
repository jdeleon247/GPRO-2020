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
	
	passTangentBasis_shadowCoord_transform_vs4x.glsl
	Calculate and pass tangent basis, and shadow coordinate.
*/

// Modified by Jonathan DeLeon

#version 450

// ****DONE:
// 1) core transformation and lighting setup:
//	-> declare data structures for projector and model matrix stacks
//		(hint: copy and slightly modify demo object descriptors)
//	-> declare uniform block for matrix data
//		(hint: must match how it is uploaded in update function)
//	-> use matrix data for current object to perform relevant transformations
//		(hint: model-view-projection sequence may be split up like last time, 
//		but per usual the final clip-space result is assigned to gl_Position)
//	-> declare relevant attributes for lighting
//	-> perform any additional transformations and write varyings for lighting
// 2) shadow mapping
//	-> using the above setup, perform additional transformation to generate a 
//		"shadow coordinate", which is a "biased clip-space" coordinate from 
//		the light's point of view
//		(hint: transformation sequence is model-view-projection-bias)
//	-> declare and write varying for shadow coordinate

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec4 aNormal;
layout (location = 8) in vec2 aTexcoord;

flat out int vVertexID;
flat out int vInstanceID;

out vec4 vNormal;
out vec4 vPosition;
out vec2 vTexcoord;
out vec4 vShadowCoord;

uniform int uIndex;

struct sProjectorMatrixStack
{
	mat4 projectionMat;
	mat4 projectionMatInverse;
	mat4 projectionBiasMat;
	mat4 projectionBiasMatInverse;
	mat4 viewProjectionMat;
	mat4 viewProjectionMatInverse;
	mat4 viewProjectionBiasMat;
	mat4 viewProjectionBiasMatInverse;
};

struct sModelMatrixStack
{
	mat4 modelMat;
	mat4 modelMatInverse;
	mat4 modelMatInverseTranspose;
	mat4 modelViewMat;
	mat4 modelViewMatInverse;
	mat4 modelViewMatInverseTranspose;
	mat4 modelViewProjectionMat;
	mat4 atlasMat;
};

uniform ubTransformStack
{
	sProjectorMatrixStack uCamera, uLight;
	sModelMatrixStack uModel[16];
};

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	vPosition = uModel[uIndex].modelViewMat * aPosition;
	vNormal = uModel[uIndex].modelViewMatInverseTranspose * aNormal;
	vTexcoord = aTexcoord;
	
	gl_Position = uCamera.projectionMat * vPosition;

	vShadowCoord = uLight.viewProjectionBiasMat * uModel[uIndex].modelMat * aPosition;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}
