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
	
	drawTangentBases_gs4x.glsl
	Draw tangent bases of vertices and/or faces, and/or wireframe shapes, 
		determined by flag passed to program.
*/

//Modified by Jonathan DeLeon

#version 450

// ****DONE: 
//	-> declare varying data to read from vertex shader
//		(hint: it's an array this time, one per vertex in primitive)
//	-> use vertex data to generate lines that highlight the input triangle
//		-> wireframe: one at each corner, then one more at the first corner to close the loop
//		-> vertex tangents: for each corner, new vertex at corner and another extending away 
//			from it in the direction of each basis (tangent, bitangent, normal)
//		-> face tangents: ditto but at the center of the face; need to calculate new bases
//	-> call "EmitVertex" whenever you're done with a vertex
//		(hint: every vertex needs gl_Position set)
//	-> call "EndPrimitive" to finish a new line and restart
//	-> experiment with different geometry effects

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 to 8 wireframe verts = 28 to 32 verts)
#define MAX_VERTICES 32

layout (triangles) in;

uniform mat4 uP;
uniform float uSize;
uniform int uFlag;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData[];

layout (line_strip, max_vertices = MAX_VERTICES) out;

out vec4 vColor;

void drawWireframe()
{
	vColor = vec4(1.0, 0.0, 0.0, 1.0);

	gl_Position = gl_in[0].gl_Position;
	EmitVertex();

	gl_Position = gl_in[1].gl_Position;
	EmitVertex();

	EndPrimitive();
	
	vColor = vec4(0.0, 1.0, 0.0, 1.0);

	gl_Position = gl_in[1].gl_Position;
	EmitVertex();

	gl_Position = gl_in[2].gl_Position;
	EmitVertex();

	EndPrimitive();


	vColor = vec4(0.0, 0.0, 1.0, 1.0);

	gl_Position = gl_in[2].gl_Position;
	EmitVertex();

	gl_Position = gl_in[0].gl_Position;
	EmitVertex();

	EndPrimitive();

}

void drawVertexTangent()
{
	vec4 tan = normalize(vVertexData[0].vTangentBasis_view[0]); // tangent
	vec4 bit = normalize(vVertexData[0].vTangentBasis_view[1]); // bitangent
	vec4 nrm = normalize(vVertexData[0].vTangentBasis_view[2]); // normal

	vColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position + tan;
	EmitVertex();
	EndPrimitive();
	
	vColor = vec4(0.0, 1.0, 0.0, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position + bit;
	EmitVertex();
	EndPrimitive();
	
	vColor = vec4(0.0, 0.0, 1.0, 1.0);
	gl_Position = gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = gl_in[0].gl_Position + nrm;
	EmitVertex();
	EndPrimitive();
}

void drawFaceTangent()
{
	vec4 faceCenterPos = (gl_in[0].gl_Position + gl_in[1].gl_Position + gl_in[2].gl_Position)/3;	//Calculate center of each triangle
	
	vec4 tan = normalize(vVertexData[0].vTangentBasis_view[0]); // tangent
	vec4 bit = normalize(vVertexData[0].vTangentBasis_view[1]); // bitangent
	vec4 nrm = normalize(vVertexData[0].vTangentBasis_view[2]); // normal

	vColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_Position = faceCenterPos;
	EmitVertex();
	gl_Position = faceCenterPos + uSize *  uP * tan;
	EmitVertex();
	EndPrimitive();

	vColor = vec4(0.0, 1.0, 0.0, 1.0);
	gl_Position = faceCenterPos;
	EmitVertex();
	gl_Position = faceCenterPos + uSize *  uP * bit;
	EmitVertex();
	EndPrimitive();

	vColor = vec4(0.0, 0.0, 1.0, 1.0);
	gl_Position = faceCenterPos;
	EmitVertex();
	gl_Position = faceCenterPos + uSize * uP * nrm;
	EmitVertex();
	EndPrimitive();
}

void main()
{
	// Pressing the key to display any of these displays them all, couldn't figure that out
	drawWireframe();
	drawVertexTangent();
	drawFaceTangent();
}
