#type vertex
#version 460 core
layout (location=0) in vec3 aPos;
layout (location=1) in vec4 aColor;
layout (location=2) in vec2 aTexCoords;
layout (location=3) in float aTexId;

uniform dmat4 uProjection;
uniform dmat4 uView;
uniform vec3 chunkOffset;
uniform bool worldRender;

out vec4 fColor;
out vec2 fTexCoords;
out float fTexId;


void main()
{
    fColor = aColor;
    fTexCoords = aTexCoords;
    fTexId = aTexId;

    if (worldRender){
        vec3 correctPos = vec3(chunkOffset + aPos);
        gl_Position = vec4(uProjection * uView * vec4(correctPos, 1.0));
    } else {
        gl_Position = vec4(uProjection * uView * vec4(aPos, 1.0));
    }

}


#type fragment
#version 460 core

in vec4 fColor;
in vec2 fTexCoords;
in float fTexId;

uniform sampler2D uTextures[256];
uniform sampler2DArray textureArray;
uniform bool useFog;
uniform bool useAtlas;
uniform float fogDistance;

uniform float fogRed;
uniform float fogGreen;
uniform float fogBlue;

out vec4 color;

vec4 setFog(vec4 color){
    float fogDepth = gl_FragCoord.z / (gl_FragCoord.w * fogDistance);
    if (fogDepth < 0){
        fogDepth = 0;
    }
    if (fogDepth > 1){
        fogDepth = 0.99;
    }
    color.x -= (color.x - fogRed) * ((fogDepth));
    color.y -= (color.y - fogGreen) * ((fogDepth));
    color.z -= (color.z - fogBlue) * ((fogDepth));
    return color;
}

void main()
{
    if (useAtlas){
        int id = int(fTexId);
        color = fColor * texture(uTextures[id], fTexCoords);
        if (useFog){
            color = setFog(color);
        }
    } else {
        float id = fTexId;
        color = fColor * texture(textureArray, vec3(fTexCoords, id));
        if (useFog){
            color = setFog(color);
        }
    }
}

