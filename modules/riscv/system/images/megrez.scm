;;; Copyright © 2025 Zheng Junjie <z572@z572.online>
(define-module (riscv system images megrez)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu packages base)
  #:use-module (guix utils)
  #:use-module (guix inferior)
  #:use-module (guix channels)
  #:use-module (srfi srfi-1)
  #:use-module (riscv packages linux)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services dns)
  #:use-module (gnu services avahi)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages wm)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages package-management)
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


(define guix*
  (package/inherit guix
    (arguments
     (substitute-keyword-arguments (package-arguments guix)
       ((#:parallel-build? parallel-build? #t)
        (if (%current-target-system)
            parallel-build?
            #t))
       ((#:tests? test? #f)
        (if (%current-target-system)
            test?
            #f))))))

(define megrez-barebones-os
  (operating-system
    (host-name "megrez")
    (timezone "Etc/UTC")
    (locale "en_US.utf8")
    (bootloader (bootloader-configuration
                 (bootloader u-boot-bootloader)
                 (targets '("/dev/null"))))
    (file-systems (cons* (file-system
                           (device (file-system-label "Guix_image"))
                           (mount-point "/")
                           (type "ext4"))
                         %base-file-systems))
    (kernel linux-rockos)
    (kernel-arguments (list "earlycon" "clk_ignore_unused"))
    (initrd-modules (cons*
                     "sd_mod"
                     (fold delete %base-initrd-modules
                           (list "hid-apple" "pata_acpi" "pata_atiixp" "isci"))))
    (firmware '())
    (packages (append (list cloud-utils)
                      (if (%current-target-system) (list)
                          (list fastfetch foot sway))
                      %base-packages))
    (services
     (append (list (service openssh-service-type
                            (openssh-configuration
                             (openssh openssh-sans-x)
                             (permit-root-login #t)
                             (allow-empty-passwords? #t)))
                   (service avahi-service-type)
                   (service dhcp-client-service-type)
                   (service ntp-service-type))
             (if (%current-target-system)
                 '()
                 (list (service elogind-service-type)))
             (modify-services %base-services
               (guix-service-type config =>
                                  (guix-configuration
                                   (inherit config)
                                   (guix guix*)
                                   (substitute-urls
                                    (list "https://ci.z572.online"
                                          "https://bordeaux.guix.gnu.org"))
                                   (build-accounts 12)
                                   (authorized-keys
                                    (append
                                     (list (plain-file "ci.z572.online"
                                                       "(public-key
 (ecc
  (curve Ed25519)
  (q #166927E5E329B2AF7E965A4AE07403B69177EB0B8556D3467A83E0BE5E3D27F9#)
  )
 )"))
                                     (list (file-append guix* "/share/guix/berlin.guix.gnu.org.pub")
                                           (file-append guix* "/share/guix/bordeaux.guix.gnu.org.pub"))))
                                   (discover? #t)
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
