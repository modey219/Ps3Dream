#pragma once
// Stub jni.h for iOS build (Android JNI types not used at runtime)

#include <stdint.h>
#include <stddef.h>

#define JNIEXPORT __attribute__((visibility("default")))
#define JNICALL
#define JNI_FALSE 0
#define JNI_TRUE 1

typedef int32_t jint;
typedef int64_t jlong;
typedef uint8_t jboolean;
typedef int8_t jbyte;
typedef float jfloat;
typedef double jdouble;
typedef jint jsize;

typedef void* jobject;
typedef jobject jclass;
typedef jobject jstring;
typedef jobject jarray;
typedef jobject jobjectArray;
typedef jobject jintArray;
typedef jobject jbyteArray;
typedef jobject jfloatArray;
typedef jobject jdoubleArray;

struct _JNIEnv;
struct _JavaVM;

typedef _JNIEnv JNIEnv;
typedef _JavaVM JavaVM;

struct JNINativeInterface;

struct _JNIEnv {
    jclass (*FindClass)(JNIEnv*, const char*);
    jobject (*NewObject)(JNIEnv*, jclass, ...);
    jobject (*NewObjectV)(JNIEnv*, jclass, void*);
    jstring (*NewStringUTF)(JNIEnv*, const char*);
    const char* (*GetStringUTFChars)(JNIEnv*, jstring, jboolean*);
    void (*ReleaseStringUTFChars)(JNIEnv*, jstring, const char*);
    jint (*GetIntField)(JNIEnv*, jobject, int);
    jlong (*GetLongField)(JNIEnv*, jobject, int);
    void (*SetIntField)(JNIEnv*, jobject, int, jint);
    void (*SetLongField)(JNIEnv*, jobject, int, jlong);
    void (*SetBooleanField)(JNIEnv*, jobject, int, jboolean);
    jboolean (*GetBooleanField)(JNIEnv*, jobject, int);
    jbyte (*GetByteField)(JNIEnv*, jobject, int);
    jfloat (*GetFloatField)(JNIEnv*, jobject, int);
    jdouble (*GetDoubleField)(JNIEnv*, jobject, int);
    jobject (*GetObjectField)(JNIEnv*, jobject, int);
    void (*SetObjectField)(JNIEnv*, jobject, int, jobject);
    jobject (*CallObjectMethod)(JNIEnv*, jobject, int, ...);
    jobject (*CallObjectMethodV)(JNIEnv*, jobject, int, void*);
    jint (*CallIntMethod)(JNIEnv*, jobject, int, ...);
    jint (*CallIntMethodV)(JNIEnv*, jobject, int, void*);
    jlong (*CallLongMethod)(JNIEnv*, jobject, int, ...);
    jboolean (*CallBooleanMethod)(JNIEnv*, jobject, int, ...);
    void (*CallVoidMethod)(JNIEnv*, jobject, int, ...);
    void (*CallVoidMethodV)(JNIEnv*, jobject, int, void*);
    jobject (*CallStaticObjectMethod)(JNIEnv*, jclass, int, ...);
    jint (*CallStaticIntMethod)(JNIEnv*, jclass, int, ...);
    void (*CallStaticVoidMethod)(JNIEnv*, jclass, int, ...);
    jboolean (*ExceptionCheck)(JNIEnv*);
    void (*ExceptionClear)(JNIEnv*);
    void (*ExceptionDescribe)(JNIEnv*);
    jobject (*NewGlobalRef)(JNIEnv*, jobject);
    void (*DeleteGlobalRef)(JNIEnv*, jobject);
    jobject (*NewLocalRef)(JNIEnv*, jobject);
    void (*DeleteLocalRef)(JNIEnv*, jobject);
    jint (*GetArrayLength)(JNIEnv*, jarray);
    jobject (*GetObjectArrayElement)(JNIEnv*, jobjectArray, jint);
    void (*SetObjectArrayElement)(JNIEnv*, jobjectArray, jint, jobject);
    jint* (*GetIntArrayElements)(JNIEnv*, jintArray, jboolean*);
    void (*ReleaseIntArrayElements)(JNIEnv*, jintArray, jint*, jint);
    jbyte* (*GetByteArrayElements)(JNIEnv*, jbyteArray, jboolean*);
    void (*ReleaseByteArrayElements)(JNIEnv*, jbyteArray, jbyte*, jint);
    void (*GetByteArrayRegion)(JNIEnv*, jbyteArray, jint, jint, jbyte*);
    void (*SetByteArrayRegion)(JNIEnv*, jbyteArray, jint, jint, const jbyte*);
    void (*GetIntArrayRegion)(JNIEnv*, jintArray, jint, jint, jint*);
    void (*SetIntArrayRegion)(JNIEnv*, jintArray, jint, jint, const jint*);
    jfieldID (*GetFieldID)(JNIEnv*, jclass, const char*, const char*);
    jfieldID (*GetStaticFieldID)(JNIEnv*, jclass, const char*, const char*);
    jmethodID (*GetMethodID)(JNIEnv*, jclass, const char*, const char*);
    jmethodID (*GetStaticMethodID)(JNIEnv*, jclass, const char*, const char*);
    jclass (*DefineClass)(JNIEnv*, const char*, jobject, const jbyte*, jsize);

    // Inline method dispatchers
    jclass FindClass(const char* name) { return FindClass(this, name); }
    jstring NewStringUTF(const char* str) { return NewStringUTF(this, str); }
    const char* GetStringUTFChars(jstring s, jboolean* b) { return GetStringUTFChars(this, s, b); }
    void ReleaseStringUTFChars(jstring s, const char* c) { ReleaseStringUTFChars(this, s, c); }
    jint GetIntField(jobject o, int f) { return GetIntField(this, o, f); }
    jlong GetLongField(jobject o, int f) { return GetLongField(this, o, f); }
    void SetIntField(jobject o, int f, jint v) { SetIntField(this, o, f, v); }
    void SetLongField(jobject o, int f, jlong v) { SetLongField(this, o, f, v); }
    void SetBooleanField(jobject o, int f, jboolean v) { SetBooleanField(this, o, f, v); }
    jboolean GetBooleanField(jobject o, int f) { return GetBooleanField(this, o, f); }
    jbyte GetByteField(jobject o, int f) { return GetByteField(this, o, f); }
    jfloat GetFloatField(jobject o, int f) { return GetFloatField(this, o, f); }
    jdouble GetDoubleField(jobject o, int f) { return GetDoubleField(this, o, f); }
    jobject GetObjectField(jobject o, int f) { return GetObjectField(this, o, f); }
    void SetObjectField(jobject o, int f, jobject v) { SetObjectField(this, o, f, v); }
    jobject NewObject(jclass cls, ...) { return nullptr; }
    jboolean ExceptionCheck() { return ExceptionCheck(this); }
    void ExceptionClear() { ExceptionClear(this); }
    void ExceptionDescribe() { ExceptionDescribe(this); }
    jobject NewGlobalRef(jobject o) { return o; }
    void DeleteGlobalRef(jobject o) { (void)o; }
    jobject NewLocalRef(jobject o) { return o; }
    void DeleteLocalRef(jobject o) { (void)o; }
    jint GetArrayLength(jarray a) { return GetArrayLength(this, a); }
    jobject GetObjectArrayElement(jobjectArray a, jint i) { return GetObjectArrayElement(this, a, i); }
    void SetObjectArrayElement(jobjectArray a, jint i, jobject o) { SetObjectArrayElement(this, a, i, o); }
    jfieldID GetFieldID(jclass c, const char* n, const char* s) { return GetFieldID(this, c, n, s); }
    jfieldID GetStaticFieldID(jclass c, const char* n, const char* s) { return GetStaticFieldID(this, c, n, s); }
    jmethodID GetMethodID(jclass c, const char* n, const char* s) { return GetMethodID(this, c, n, s); }
    jmethodID GetStaticMethodID(jclass c, const char* n, const char* s) { return GetStaticMethodID(this, c, n, s); }
    jclass GetObjectClass(jobject o) { return nullptr; }
};

typedef jint (*JNI_OnLoad_func)(JavaVM*, void*);

struct _JavaVM {
    jint (*GetEnv)(JavaVM*, void**, jint);
    jint (*AttachCurrentThread)(JavaVM*, JNIEnv**, void*);
    jint (*DetachCurrentThread)(JavaVM*);
    jint (*GetDefaultJavaVMInitArgs)(void*);

    jint GetEnv(void** env, jint ver) { return GetEnv(this, env, ver); }
    jint AttachCurrentThread(JNIEnv** env, void* a) { return AttachCurrentThread(this, env, a); }
};

// JNI field/method IDs
typedef void* jfieldID;
typedef void* jmethodID;

#define JNI_VERSION_1_6 0x00010006
