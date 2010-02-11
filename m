From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 11 Feb 2010 14:42:26 -0500
Subject: [PATCH 0 of 12] LVM add 'mirrored' log type
In-Reply-To: <1265402083.14189.2.camel@hydrogen.msp.redhat.com>
References: <1265402083.14189.2.camel@hydrogen.msp.redhat.com>
Message-ID: <4B745DA2.4010403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> The following set of patches adds the 'mirrored' log type.  It differs
> from the last batch by changing the name of the log type
> (s/redundant/mirrored/), fixing all the issues uncovered by the
> testsuite, adding new test cases, and including log monitoring (provided
> by Malahal Naineni).

I found other two cases which caused Segmentation Fault.

# lvcreate --version
  LVM version:     2.02.61(1)-cvs (2010-02-02)
  Library version: 1.02.44-cvs (2010-02-02)
  Driver version:  4.16.0

Tests are done with lvm2, 2.02.61(1)-cvs (2010-02-02) with this
patch set, and vg00 contains just one PV.

[case 1]
# lvcreate -m1 -L12m -nlv00 --mirrorlog mirrored --alloc anywhere vg00
Segmentation fault

[case 2]
# dmsetup table
vg00-lv00: 0 24576 linear 8:32 384
# lvconvert -m1 --mirrorlog mirrored --alloc anywhere vg00/lv00
Segmentation fault

In both cases, initialization of log_areas array seems to have a problem.

Thanks,
Taka



