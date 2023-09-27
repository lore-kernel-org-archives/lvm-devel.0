From: Adam Joseph <adam@westernsemico.com>
Date: Tue, 26 Sep 2023 21:14:09 -0700
Subject: [PATCH] autoconf: handle the standard --disable-shared flag
In-Reply-To: <e0bc7bc7-027b-45d6-84a2-c73bf68672c4@gmail.com>
References: <20230922064737.31282-2-adam@westernsemico.com>
 <e0bc7bc7-027b-45d6-84a2-c73bf68672c4@gmail.com>
Message-ID: <169578804917.28077.15346938084174534374@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Quoting Zdenek Kabelac (2023-09-26 12:53:59)
> The main problem with supporting anything for 'static' linkage is rather a
> lack of 'known' system that can be build with 'static' library of all other
> used libraries - and actually be usable.

Oh it's quite usable; I've been using it on both my laptop and workstations for
over a year.  See below.  Until recently I was using LVM 2.02 where all of this
just worked with no patches; the submitted patch is necessary in order to fix a
regression in LVM 2.03.

> I.e.  static udev or static systemd

I don't use either of those.  They are absent at compile time; lvm's configury
notices this and disables them correctly.

> What libraries are present for usage ?

There are no .so files at runtime.  None whatsoever.  Anywhere.

> So what is the system you are using ?

At build time, nixpkgs (not nixos), statically linked against musl libc:

  https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/lvm2/common.nix

At runtime, ownerboot:

  https://sr.ht/~amjoseph/ownerboot/

The kernel, lvm2, and cryptsetup are all stored on the SPI flash chip, allowing
to completely encrypt the *entire* disk -- which UEFI is not capable of doing.
The SPI flash chip is hardware write-protected (another thing most UEFIs can't
tolerate) by shorting the WE# pin.  This leaves no unencrypted writeable media
anywhere on the system.

The minimal early system kexec()s another long-lived kernel loaded from the
decrypted disk.  It's very similar to what powerpc64 users do with petitboot,
except that it's for amd64 and arm64.

> Do you purly target to have  'libdm' portion to be linked as static
> (aka only 'dmsetup' resulting binary - or do you need 'dmeventd' ,
> or mayby  libdevmapper.a  ?)

I personally need only dmsetup and lvm2 (within the dm-crypt volume is an lvm2
pv).  I don't use dmeventd.  However I do also include a statically-linked
cryptsetup, which I believe links against libdevmapper.a (I would have to check
to be sure).

However it's qute difficult to build a small cryptsetup binary -- their build
process does not provide any way to compile out unnecessary things like
bitlocker and veracrypt.  Even using kernel crypto instead of openssl it's still
1.8Mbytes.  I intend to move towards using dmsetup directly in order to save
space.

  - a

