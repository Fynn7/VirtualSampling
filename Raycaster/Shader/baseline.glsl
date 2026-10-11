uniform sampler3D targetMask;
uniform int maskEnabled;
uniform float maskContextAlpha;
void main() {
  result = vec4(0.0);
  vec3 rayDir = normalize(entryPoint-cameraPosInTextureSpace);

  float samples = dot(abs(rayDir),voxelCount);
  float opacityCorrection = opacityReference/(samples*oversampling);
  vec3 delta = rayDir/(samples*oversampling);

  vec3 currentPoint = entryPoint;
  do {
    float reconstruction = reconstructValue(currentPoint);
    if(maskEnabled==0)processPoint(reconstruction, opacityCorrection);
    else {
      ivec3 cell=clamp(ivec3(floor(currentPoint*voxelCount+0.5)),ivec3(0),ivec3(voxelCount)-1);
      float spatialAlpha=texelFetch(targetMask,cell,0).r>0.5?1.0:maskContextAlpha;
      if(spatialAlpha>0.0) {
        vec4 classified=transferFunction(reconstruction);
        classified.a=1.0-pow(1.0-classified.a,opacityCorrection*spatialAlpha);
        result=under(classified,result);
      }
    }
    if (result.a > alphaThreshold) return;
    currentPoint += delta;
  } while (inBounds(currentPoint));
}
