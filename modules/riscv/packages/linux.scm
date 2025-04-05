(define-module (riscv packages linux)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages acl)
  #:use-module (gnu packages adns)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages apparmor)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages calendar)
  #:use-module (gnu packages check)
  #:use-module (gnu packages cpio)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages cryptsetup)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages datastructures)
  #:use-module (gnu packages dbm)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages docbook)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages dlang)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages file)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libunwind)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages lsof)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages netpbm)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages onc-rpc)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages popt)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages regex)
  #:use-module (gnu packages rpc)
  #:use-module (gnu packages rrdtool)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages samba)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages slang)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tbb)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages valgrind)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages groff)
  #:use-module (gnu packages selinux)
  #:use-module (gnu packages sphinx)
  #:use-module (gnu packages swig)
  #:use-module (guix platform)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system go)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (guix build-system qt)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system linux-module)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix store)
  #:use-module (guix monads)
  #:use-module (guix utils)
  #:use-module (guix deprecation)    ;for libcap/next
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex))

(define-public linux-rockos
  (let* ((version "6.6.83")
         (commit "5d8e55ae695aab5afed6acfabe14bdad12c28013"))
    (customize-linux
     #:name "linux-rockos"
     #:linux (package (inherit linux-libre-6.6)
                      (version version))
     #:defconfig "win2030_defconfig"
     #:extra-version "rockos"
     #:source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/rockos-riscv/rockos-kernel/")
             (commit commit)))
       (file-name
        (git-file-name
         "rockos-kernel"
         (git-version version "0" commit)))
       (sha256
        (base32
         "13clchza3himyi9hd6x1bh597nyz9q3z3fqbg0j109ni9v5nr4ah"))
       (modules '((guix build utils)))
       (snippet
        #~(substitute* "drivers/gpu/drm/amd/amdkfd/Kconfig"
            (("depends on DRM_AMDGPU && [(]X86_64 [|][|] ARM64 [|][|] PPC64[)]")
             "depends on DRM_AMDGPU && (X86_64 || ARM64 || PPC64 || RISCV)"))))
     #:configs '("CONFIG_HID_GENERIC=m"
                 "CONFIG_USB_UAS=m"
                 "CONFIG_CRYPTO_XTS=m"
                 "CONFIG_CRYPTO_SERPENT=m"
                 "CONFIG_CRYPTO_WP512=m"
                 "CONFIG_HW_RANDOM_VIRTIO=m"
                 "CONFIG_VIRTIO_CONSOLE=m"
                 "CONFIG_USB_STORAGE=m"
                 "CONFIG_VIRTIO_BLK=m"
                 "CONFIG_VIRTIO_PCI=m"
                 "CONFIG_VIRTIO_BALLOON=m"
                 ;; "CONFIG_HID_APPLE=m"
                 ;; "CONFIG_PATA_ACPI=m"
                 ;; "CONFIG_PATA_ATIIXP=m"
                 ;; "CONFIG_SCSI_ISCI=m"

                 "CONFIG_MODPROBE_PATH=\"/run/current-system/profile/bin/modprobe\""
                 "CONFIG_FW_LOADER_USER_HELPER=y"
                 "CONFIG_FW_LOADER_COMPRESS=y"
                 "CONFIG_FW_LOADER_COMPRESS_ZSTD=y"
                 "CONFIG_FW_UPLOAD=y"
                 "CONFIG_HSA_AMD=y"
                 "CONFIG_ZRAM=m"
                 "CONFIG_MODULE_COMPRESS_ZSTD=y"
                 "CONFIG_MODULE_DECOMPRESS=y"

                 "CONFIG_NUMA=y"))))
