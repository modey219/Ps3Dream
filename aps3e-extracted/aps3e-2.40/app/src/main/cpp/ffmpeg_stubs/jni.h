#pragma once
// Minimal JNI stub for iOS build

#include <stdint.h>
#include <stddef.h>

#define JNIEXPORT __attribute__((visibility("default")))
#define JNICALL
#define JNI_FALSE 0
#define JNI_TRUE 1
#define JNI_VERSION_1_6 0x00010006

typedef int32_t jint;
typedef int64_t jlong;
typedef uint8_t jboolean;
typedef int8_t jbyte;
typedef uint16_t jchar;
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
typedef jobject jcharArray;
typedef void* jfieldID;
typedef void* jmethodID;

struct JNINativeMethod {
    const char* name;
    const char* signature;
    void* fnPtr;
};

struct JNIEnv_;
struct JavaVM_;
typedef JNIEnv_ JNIEnv;
typedef JavaVM_ JavaVM;

struct JNINativeInterface_ {
    void* reserved0; void* reserved1; void* reserved2; void* reserved3;
    jclass (*FindClass)(JNIEnv*, const char*);
    jmethodID (*GetMethodID)(JNIEnv*, jclass, const char*, const char*);
    jmethodID (*GetStaticMethodID)(JNIEnv*, jclass, const char*, const char*);
    jfieldID (*GetFieldID)(JNIEnv*, jclass, const char*, const char*);
    jfieldID (*GetStaticFieldID)(JNIEnv*, jclass, const char*, const char*);
    jobject (*CallObjectMethodV)(JNIEnv*, jobject, jmethodID, void*);
    jint (*CallIntMethodV)(JNIEnv*, jobject, jmethodID, void*);
    jlong (*CallLongMethodV)(JNIEnv*, jobject, jmethodID, void*);
    jboolean (*CallBooleanMethodV)(JNIEnv*, jobject, jmethodID, void*);
    void (*CallVoidMethodV)(JNIEnv*, jobject, jmethodID, void*);
    jobject (*CallStaticObjectMethodV)(JNIEnv*, jclass, jmethodID, void*);
    jint (*CallStaticIntMethodV)(JNIEnv*, jclass, jmethodID, void*);
    void (*CallStaticVoidMethodV)(JNIEnv*, jclass, jmethodID, void*);
    jstring (*NewStringUTF)(JNIEnv*, const char*);
    const char* (*GetStringUTFChars)(JNIEnv*, jstring, jboolean*);
    void (*ReleaseStringUTFChars)(JNIEnv*, jstring, const char*);
    jobject (*NewObjectV)(JNIEnv*, jclass, jmethodID, void*);
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
    jboolean (*ExceptionCheck)(JNIEnv*);
    void (*ExceptionClear)(JNIEnv*);
    void (*ExceptionDescribe)(JNIEnv*);
    jobject (*NewGlobalRef)(JNIEnv*, jobject);
    void (*DeleteGlobalRef)(JNIEnv*, jobject);
    jobject (*NewLocalRef)(JNIEnv*, jobject);
    void (*DeleteLocalRef)(JNIEnv*, jobject);
    jclass (*GetObjectClass)(JNIEnv*, jobject);
    jclass (*DefineClass)(JNIEnv*, const char*, jobject, const jbyte*, jsize);
    jobject (*NewObjectArray)(JNIEnv*, jint, jclass, jobject);
    jstring (*NewString)(JNIEnv*, const jchar*, jsize);
    void (*SetBooleanField)(JNIEnv*, jobject, jfieldID, jboolean);
    void (*SetIntField)(JNIEnv*, jobject, jfieldID, jint);
    void (*SetLongField)(JNIEnv*, jobject, jfieldID, jlong);
    void (*SetObjectField)(JNIEnv*, jobject, jfieldID, jobject);
    jboolean (*GetBooleanField)(JNIEnv*, jobject, jfieldID);
    jint (*GetIntField)(JNIEnv*, jobject, jfieldID);
    jlong (*GetLongField)(JNIEnv*, jobject, jfieldID);
    jobject (*GetObjectField)(JNIEnv*, jobject, jfieldID);
    jfloat (*GetFloatField)(JNIEnv*, jobject, jfieldID);
    jdouble (*GetDoubleField)(JNIEnv*, jobject, jfieldID);
    jbyte (*GetByteField)(JNIEnv*, jobject, jfieldID);
    jint (*RegisterNatives)(JNIEnv*, jclass, const JNINativeMethod*, jint);
    jboolean (*IsInstanceOf)(JNIEnv*, jobject, jclass);
    jbyteArray (*NewByteArray)(JNIEnv*, jsize);
    void (*SetByteField)(JNIEnv*, jobject, jfieldID, jbyte);
    void (*SetShortField)(JNIEnv*, jobject, jfieldID, jshort);
    jshort (*GetShortField)(JNIEnv*, jobject, jfieldID);
    jchar (*GetCharField)(JNIEnv*, jobject, jfieldID);
    void (*SetCharField)(JNIEnv*, jobject, jfieldID, jchar);
    jfloat (*GetFloatField2)(JNIEnv*, jobject, jfieldID);
    void (*SetFloatField)(JNIEnv*, jobject, jfieldID, jfloat);
    jdouble (*GetDoubleField2)(JNIEnv*, jobject, jfieldID);
    void (*SetDoubleField)(JNIEnv*, jobject, jfieldID, jdouble);
    void (*SetStaticBooleanField)(JNIEnv*, jclass, jfieldID, jboolean);
    void (*SetStaticObjectField)(JNIEnv*, jclass, jfieldID, jobject);
    jobject (*CallNonvirtualObjectMethodV)(JNIEnv*, jobject, jclass, jmethodID, void*);
    jint (*CallNonvirtualIntMethodV)(JNIEnv*, jobject, jclass, jmethodID, void*);
    jboolean (*ExceptionOccurred)(JNIEnv*);
    void (*MonitorEnter)(JNIEnv*, jobject);
    void (*MonitorExit)(JNIEnv*, jobject);
    jobject (*NewDirectByteBuffer)(JNIEnv*, void*, jlong);
    void* (*GetDirectBufferAddress)(JNIEnv*, jobject);
};

struct JNIEnv_ {
    const JNINativeInterface_* functions;
    jclass FindClass(const char* n) { return functions->FindClass(this, n); }
    jmethodID GetMethodID(jclass c, const char* n, const char* s) { return functions->GetMethodID(this, c, n, s); }
    jmethodID GetStaticMethodID(jclass c, const char* n, const char* s) { return functions->GetStaticMethodID(this, c, n, s); }
    jfieldID GetFieldID(jclass c, const char* n, const char* s) { return functions->GetFieldID(this, c, n, s); }
    jfieldID GetStaticFieldID(jclass c, const char* n, const char* s) { return functions->GetStaticFieldID(this, c, n, s); }
    jstring NewStringUTF(const char* s) { return functions->NewStringUTF(this, s); }
    const char* GetStringUTFChars(jstring s, jboolean* b) { return functions->GetStringUTFChars(this, s, b); }
    void ReleaseStringUTFChars(jstring s, const char* c) { functions->ReleaseStringUTFChars(this, s, c); }
    jint GetArrayLength(jarray a) { return functions->GetArrayLength(this, a); }
    jobject GetObjectArrayElement(jobjectArray a, jint i) { return functions->GetObjectArrayElement(this, a, i); }
    void SetObjectArrayElement(jobjectArray a, jint i, jobject o) { functions->SetObjectArrayElement(this, a, i, o); }
    jobject NewGlobalRef(jobject o) { return functions->NewGlobalRef(this, o); }
    void DeleteGlobalRef(jobject o) { functions->DeleteGlobalRef(this, o); }
    jobject NewLocalRef(jobject o) { return functions->NewLocalRef(this, o); }
    void DeleteLocalRef(jobject o) { functions->DeleteLocalRef(this, o); }
    jclass GetObjectClass(jobject o) { return functions->GetObjectClass(this, o); }
    jboolean ExceptionCheck() { return functions->ExceptionCheck(this); }
    void ExceptionClear() { functions->ExceptionClear(this); }
    void ExceptionDescribe() { functions->ExceptionDescribe(this); }
    void SetBooleanField(jobject o, jfieldID f, jboolean v) { functions->SetBooleanField(this, o, f, v); }
    void SetIntField(jobject o, jfieldID f, jint v) { functions->SetIntField(this, o, f, v); }
    void SetLongField(jobject o, jfieldID f, jlong v) { functions->SetLongField(this, o, f, v); }
    void SetObjectField(jobject o, jfieldID f, jobject v) { functions->SetObjectField(this, o, f, v); }
    jboolean GetBooleanField(jobject o, jfieldID f) { return functions->GetBooleanField(this, o, f); }
    jint GetIntField(jobject o, jfieldID f) { return functions->GetIntField(this, o, f); }
    jlong GetLongField(jobject o, jfieldID f) { return functions->GetLongField(this, o, f); }
    jobject GetObjectField(jobject o, jfieldID f) { return functions->GetObjectField(this, o, f); }
    jfloat GetFloatField(jobject o, jfieldID f) { return functions->GetFloatField(this, o, f); }
    jdouble GetDoubleField(jobject o, jfieldID f) { return functions->GetDoubleField(this, o, f); }
    jbyte GetByteField(jobject o, jfieldID f) { return functions->GetByteField(this, o, f); }
    jobject NewObject(jclass c, jmethodID m, ...) { return nullptr; }
    jint* GetIntArrayElements(jintArray a, jboolean* b) { return functions->GetIntArrayElements(this, a, b); }
    void ReleaseIntArrayElements(jintArray a, jint* e, jint m) { functions->ReleaseIntArrayElements(this, a, e, m); }
    jbyte* GetByteArrayElements(jbyteArray a, jboolean* b) { return functions->GetByteArrayElements(this, a, b); }
    void ReleaseByteArrayElements(jbyteArray a, jbyte* e, jint m) { functions->ReleaseByteArrayElements(this, a, e, m); }
    void GetByteArrayRegion(jbyteArray a, jint s, jint l, jbyte* b) { functions->GetByteArrayRegion(this, a, s, l, b); }
    void SetByteArrayRegion(jbyteArray a, jint s, jint l, const jbyte* b) { functions->SetByteArrayRegion(this, a, s, l, b); }
    void GetIntArrayRegion(jintArray a, jint s, jint l, jint* b) { functions->GetIntArrayRegion(this, a, s, l, b); }
    void SetIntArrayRegion(jintArray a, jint s, jint l, const jint* b) { functions->SetIntArrayRegion(this, a, s, l, b); }
    jobject NewObjectArray(jint l, jclass c, jobject i) { return functions->NewObjectArray(this, l, c, i); }
    jclass DefineClass(const char* n, jobject l, const jbyte* b, jsize s) { return functions->DefineClass(this, n, l, b, s); }
    jobject CallObjectMethod(jobject o, jmethodID m, ...) { return nullptr; }
    jint CallIntMethod(jobject o, jmethodID m, ...) { return 0; }
    jlong CallLongMethod(jobject o, jmethodID m, ...) { return 0; }
    jboolean CallBooleanMethod(jobject o, jmethodID m, ...) { return 0; }
    void CallVoidMethod(jobject o, jmethodID m, ...) {}
    jobject CallStaticObjectMethod(jclass c, jmethodID m, ...) { return nullptr; }
    jint CallStaticIntMethod(jclass c, jmethodID m, ...) { return 0; }
    void CallStaticVoidMethod(jclass c, jmethodID m, ...) {}
    void SetStaticIntField(jclass c, jfieldID f, jint v) {}
    jint RegisterNatives(jclass c, const JNINativeMethod* m, jint n) { return functions->RegisterNatives(this, c, m, n); }
    jboolean IsInstanceOf(jobject o, jclass c) { return functions->IsInstanceOf(this, o, c); }
    jbyteArray NewByteArray(jsize s) { return functions->NewByteArray(this, s); }
    void SetByteField(jobject o, jfieldID f, jbyte v) { functions->SetByteField(this, o, f, v); }
    void SetShortField(jobject o, jfieldID f, jshort v) { functions->SetShortField(this, o, f, v); }
    jshort GetShortField(jobject o, jfieldID f) { return functions->GetShortField(this, o, f); }
    jchar GetCharField(jobject o, jfieldID f) { return functions->GetCharField(this, o, f); }
    void SetCharField(jobject o, jfieldID f, jchar v) { functions->SetCharField(this, o, f, v); }
    void SetFloatField(jobject o, jfieldID f, jfloat v) { functions->SetFloatField(this, o, f, v); }
    void SetDoubleField(jobject o, jfieldID f, jdouble v) { functions->SetDoubleField(this, o, f, v); }
    void SetStaticBooleanField(jclass c, jfieldID f, jboolean v) { functions->SetStaticBooleanField(this, c, f, v); }
    void SetStaticObjectField(jclass c, jfieldID f, jobject v) { functions->SetStaticObjectField(this, c, f, v); }
    jboolean ExceptionOccurred() { return functions->ExceptionOccurred(this); }
    void MonitorEnter(jobject o) { functions->MonitorEnter(this, o); }
    void MonitorExit(jobject o) { functions->MonitorExit(this, o); }
    jobject NewDirectByteBuffer(void* a, jlong s) { return functions->NewDirectByteBuffer(this, a, s); }
    void* GetDirectBufferAddress(jobject o) { return functions->GetDirectBufferAddress(this, o); }
};

struct JavaVM_ {
    jint (*_GetEnv)(JavaVM*, void**, jint);
    jint (*_AttachCurrentThread)(JavaVM*, JNIEnv**, void*);
    jint (*_DetachCurrentThread)(JavaVM*);
    jint GetEnv(void** env, jint ver) { return _GetEnv(this, env, ver); }
    jint AttachCurrentThread(JNIEnv** env, void* a) { return _AttachCurrentThread(this, env, a); }
    jint DetachCurrentThread() { return _DetachCurrentThread(this); }
};

inline jint JNI_GetDefaultJavaVMInitArgs(void* args) { return -1; }
inline jint JNI_CreateJavaVM(JavaVM** vm, void** env, void* args) { return -1; }

typedef jint (*JNI_OnLoad_func)(JavaVM*, void*);
