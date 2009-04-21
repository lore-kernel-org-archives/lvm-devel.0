From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 21 Apr 2009 14:35:23 -0400
Subject: [PATCH 1/4] Udev integration: add LVM fields support for dmsetup
In-Reply-To: <49DC94D2.4010903@redhat.com>
References: <49DC94D2.4010903@redhat.com>
Message-ID: <1240338923.3705.66.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A couple minor cleanup comments for this patch set:
1. Warnings when compiling these patches. 
ioctl/libdm-iface.c:867: warning: no previous prototype for ?dm_cookie_supported?
dmsetup.c:332: warning: assignment discards qualifiers from pointer target type

2. whitespace / tabs - set to 8 spaces / tab?
Areas I noticed were dm_cookie_supported() definitions and other
indents.


