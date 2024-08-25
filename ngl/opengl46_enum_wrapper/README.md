# Enum-Enhanced OpenGL 4.6 Wrapper for Odin Programming Language

Categorizes the GL enums into groups and integrates them into the procedures, ensuring that only the correct enums are utilized. \
Builds on the **vendor:OpenGL** library by vassvik.

Three sources were used (with decreasing priority):
- [OpenGL 4.6 Core Profile Specification](opengl46-core-profile-specification.pdf), as of 5th May 2022
- [OpenGL 4.6 API Reference Guide](opengl46-api-reference-guide.pdf), Rev. 0717
- [OpenGL 4.5 Reference Pages](https://registry.khronos.org/OpenGL-Refpages/gl4/) (registry.khronos.org)

Due to numerous errors in the Reference Guide, the majority of the implementation was derived from the Specification and cross-verified with the other sources, when the Specification was not clear enough. There still might be errors. Pointing them out would be appreciated.

## Approach
- Enums are in Ada_Case.
- Naming is mostly conservative for recognizability.
- All procedure signatures are present, wherever an enum was added.
- There are only a handful of references to other files.
- There are not many typedefs.
- The formatting of wrappers.odin will be neglected until the code is stable.

## Licensing
Available under the MIT license. See [OpenGL/LICENSE](OpenGL/LICENSE).

## Contribute
Certainly this wrapper needs a lot of polishing. \
Feel free to contribute!
