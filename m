From: Bryn M. Reeves <breeves@redhat.com>
Date: Wed, 03 Oct 2007 11:03:24 +0100
Subject: Re: LVM2/tools/fsadm Makefile.in
In-Reply-To: <20071003095830.GH18444@agk.fab.redhat.com>
References: <20071003094658.15588.qmail@sourceware.org>
	<20071003095830.GH18444@agk.fab.redhat.com>
Message-ID: <470368EC.5030601@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alasdair G Kergon wrote:
> On Wed, Oct 03, 2007 at 09:46:58AM -0000, meyering at sourceware.org wrote:
>> 	* tools/fsadm/Makefile.in (LVMLIBS): Define.
>> 	(fsadm): Link with $(LVMLIBS).
>  
>>  fsadm: $(OBJECTS)
>> -	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
>> +	$(CC) -o $@ $(CFLAGS) $(OBJECTS) $(LDFLAGS) $(LVMLIBS) -rdynamic
>   
> fsadm is meant to be independent of LVM2 so should not be using LVMLIBS.
> What should be done to deal with this?

It's just one call in the _usage function that was formerly a call to
basename. Eliminating basename usage in LVM2 is a good thing, but
perhaps this one should be left as-was until fsadm has a more complete
implementation?

Bryn.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFHA2js6YSQoMYUY94RAmR+AJ0QkCJl+lVIf6YHSJI+tUWFvNmtZgCgjTjR
Yz5WkTwgMh8ag/xZxXAdQps=
=WaXe
-----END PGP SIGNATURE-----


