From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 21 Jun 2013 15:53:29 +0200
Subject: Internal error: Pool read_vg crc mismatch only when running in test environment
In-Reply-To: <51C38DB6.7070507@redhat.com>
References: <51C38DB6.7070507@redhat.com>
Message-ID: <51C45AD9.2040703@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.6.2013 01:18, Tony Asleson napsal(a):
> Writing some new unit test cases for my latest liblvm patch set and at
> the moment I am running into a case where I can run the unit test case
> against real disk and it works, but if I run it in the test environment
> with loop back devices I am getting an abort with:
>
> "Internal error: Pool read_vg crc mismatch."
>
> Any ideas why this error isn't occurring on both?
>

This happens - if you have requested 'read-only'  VG struct,
and you have modifed something in this vgmem pool
(either writing to struct, or just using vgmem pool for allocation)

Zdenek


