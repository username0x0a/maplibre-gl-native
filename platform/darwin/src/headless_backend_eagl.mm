#include <mbgl/gl/headless_backend.hpp>

#include <MetalANGLE/MGLContext.h>

#include <stdexcept>

namespace mbgl {
namespace gl {

class EAGLBackendImpl : public HeadlessBackend::Impl {
public:
    EAGLBackendImpl() {
        glContext = [[MGLContext alloc] initWithAPI:kMGLRenderingAPIOpenGLES2];
        if (glContext == nil) {
            throw std::runtime_error("Error creating GL context object");
        }
//        glContext.multiThreaded = YES;
    }

    // Required for ARC to deallocate correctly.
    ~EAGLBackendImpl() final = default;

    gl::ProcAddress getExtensionFunctionPointer(const char* name) final {
        static CFBundleRef framework = CFBundleGetBundleWithIdentifier(CFSTR("com.apple.opengles"));
        if (!framework) {
            throw std::runtime_error("Failed to load OpenGL framework.");
        }

        return reinterpret_cast<gl::ProcAddress>(CFBundleGetFunctionPointerForName(
            framework, (__bridge CFStringRef)[NSString stringWithUTF8String:name]));
    }

    void activateContext() final {
        [MGLContext setCurrentContext:glContext];
    }

    void deactivateContext() final {
        [MGLContext setCurrentContext:nil];
    }

private:
    MGLContext* glContext = nullptr;
};

void HeadlessBackend::createImpl() {
    assert(!impl);
    impl = std::make_unique<EAGLBackendImpl>();
}

} // namespace gl
} // namespace mbgl
