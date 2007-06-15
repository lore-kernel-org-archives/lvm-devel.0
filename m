From: Bryn M. Reeves <breeves@redhat.com>
Date: Fri, 15 Jun 2007 17:12:05 +0100
Subject: [PATCH] allow filenames with vgcfgrestore -l
In-Reply-To: <1181923727.3687.24.camel@linux-cxyg>
References: <46673CE4.4010801@redhat.com> <1181923727.3687.24.camel@linux-cxyg>
Message-ID: <4672BA55.4010700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Dave Wysochanski wrote:
> On Thu, 2007-06-07 at 00:01 +0100, Bryn M. Reeves wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Simple patch to permit a metadata backup file to be specified on the
>> vgcfgrestore command line using -f when listing backups, for e.g.:
>>
>> vgcfgrestore -l -f /tmp/VolGroup
>>
>> LVM1 allowed this behavior and it's been requested a couple of times on
>> the mailing list.
>>
> 
> Bryn I just checked in fixes to the vgcfgrestore man pg.  Could you take
> a look and see if it is ok?
> 

Dave,

Looks good to me - thanks! I wasn't sure how to word it but I think your
changes make it clear.

The change to add -f was motivated by the fact that users found the man
page confusing as it didn't forbid -f with -l and people found this
ambiguous as LVM1 allowed that - I think your changes clear this up.

Regards,
Bryn.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGcrpV6YSQoMYUY94RAi8hAJ4zQqEVlV+FOt//2QDTH5W9WLmINgCeJ8R9
Eb95R/f8g72c56y2XS6RYe4=
=nrBZ
-----END PGP SIGNATURE-----


