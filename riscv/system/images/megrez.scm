;;; Copyright © 2025 Zheng Junjie <z572@z572.online>
(define-module (riscv system images megrez)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu packages base)
  #:use-module (guix inferior)
  #:use-module (guix channels)
  #:use-module (srfi srfi-1)
  #:use-module (riscv packages linux)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu services dbus)
  #:use-module (gnu services dns)
  #:use-module (gnu services avahi)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu image)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:use-module (guix packages)

  #:use-module (gnu packages ssh)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages admin)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (guix platforms riscv)
  #:use-module (srfi srfi-26)
  #:use-module (gnu bootloader extlinux)
  #:export (megrez-barebones-os
            megrez-image-type
            megrez-barebones-raw-image))


(define megrez-barebones-os
  (operating-system
    (host-name "megrez")
    (timezone "Etc/UTC")
    (locale "en_US.utf8")
    (bootloader (bootloader-configuration
                 (bootloader u-boot-bootloader)
                 (targets '("/dev/null"))))
    (file-systems (cons* (file-system
                           (device (file-system-label "root"))
                           (mount-point "/")
                           (type "ext4"))
                         %base-file-systems))
    (kernel linux-rockos)
    (kernel-arguments (list "earlycon" "clk_ignore_unused"))
    (initrd-modules (fold delete %base-initrd-modules
                          (list "wp512"
                                "virtio_pci"
                                "virtio_balloon" "virtio_blk" "virtio_net"
                                "virtio_console" "virtio-rng"
                                "serpent_generic"
                                "xts"
                                "hid-generic"
                                "usb-storage")))
    (firmware '())
    (packages (append (list cloud-utils) %base-packages))
    (services
     (append (list (service openssh-service-type
                            (openssh-configuration
                             (openssh openssh-sans-x)
                             (permit-root-login #t)
                             (allow-empty-passwords? #t)))
                   ;; XXX: Does it need this?
                   (service agetty-service-type
                            (agetty-configuration
                             (extra-options '("-L"))
                             (baud-rate "115200")
                             (term "vt100")
                             (tty "ttySIF0")))
                   (service dhcp-client-service-type))
             (modify-services %base-services
               (guix-service-type config =>
                                  (guix-configuration
                                   (inherit config)
                                   (substitute-urls
                                    (list "https://ci.z572.online"
                                          "https://bordeaux.guix.gnu.org" ))
                                   (build-accounts 4)
                                   (authorized-keys
                                    (append
                                     (list (plain-file "ci.z572.online"
                                                       "(public-key
 (ecc
  (curve Ed25519)
  (q #166927E5E329B2AF7E965A4AE07403B69177EB0B8556D3467A83E0BE5E3D27F9#)
  )
 )"))
                                     %default-authorized-guix-keys))
                                   (discover? #f)
                                   (extra-options
                                    (list "-M 4" "-c 4")))))))))

(define megrez-image-type
  (image-type
   (name 'megrez-raw)
   (constructor
    (lambda (os)
      (image
       (inherit (raw-with-offset-disk-image (expt 2 24)))
       (operating-system os)
       (platform riscv64-linux))))))

(define megrez-barebones-raw-image
  (image
   (inherit
    (os+platform->image megrez-barebones-os riscv64-linux
                        #:type megrez-image-type))
   (name 'megrez-barebones-raw-image)))

;; Return the default image.
megrez-barebones-raw-image
