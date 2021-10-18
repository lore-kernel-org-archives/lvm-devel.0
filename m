From: Yureka <yuka@yuka.dev>
Date: Mon, 18 Oct 2021 18:31:21 +0200
Subject: LVM2/libdm build system
Message-ID: <16d0cea1-35bd-f6d8-b307-33aba881951d@yuka.dev>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hey everyone,


I recently had to deal with the LVM2 build system a bit, and it was
horrible. For example, in an environment where only static libraries
(.a) are available, the build system would still try to build
libdevmapper.so and fail. Also it was not easily possible to build only
the libdm portions of the code base.

The question: Would it be thinkable to switch the build system to
something more modern like Meson or CMake? Are the maintainers
interested in contributions like this?


Thanks,

Yureka


