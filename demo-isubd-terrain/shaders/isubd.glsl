#line 1

uint parentKey(in uint key)
{
    return (key >> 1u);
}

void childrenKeys(in uint key, out uint children[2])
{
    children[0] = (key << 1u) | 0u;
    children[1] = (key << 1u) | 1u;
}

bool isChildZero(in uint key)
{
    return ((key & 1u) == 0u);
}

bool isRoot(in uint key)
{
    return key == 1u;
}

bool isLeaf(in uint key)
{
    return findMSB(key) == 31;
}

// get xform from bit value
mat3 bitToXform(in uint bit)
{
    float s = float(bit) - 0.5;
    vec3 c1 = vec3(   s, -0.5, 0);
    vec3 c2 = vec3(-0.5,   -s, 0);
    vec3 c3 = vec3(+0.5, +0.5, 1);

    return mat3(c1, c2, c3);
}

// get xform from key
mat3 keyToXform(in uint key)
{
    mat3 xf = mat3(1.0f);

    while (key > 1u) {
        xf = bitToXform(key & 1u) * xf;
        key = key >> 1u;
    }

    return xf;
}

// barycentric interpolation
vec3 berp(in vec3 v[3], in vec2 u)
{
    return v[0] + u.x * (v[1] - v[0]) + u.y * (v[2] - v[0]);
}

// subdivision routine (vertex position only)
void subd(in uint key, in vec3 v_in[3], out vec3 v_out[3])
{
    mat3 xf = keyToXform(key);
    vec2 u1 = (xf * vec3(0, 0, 1)).xy;
    vec2 u2 = (xf * vec3(1, 0, 1)).xy;
    vec2 u3 = (xf * vec3(0, 1, 1)).xy;

    v_out[0] = berp(v_in, u1);
    v_out[1] = berp(v_in, u2);
    v_out[2] = berp(v_in, u3);
}

float distanceToLod(float z, float lodFactor)
{
    return -log2(clamp(z * lodFactor, 0.0f, 1.0f));
}
