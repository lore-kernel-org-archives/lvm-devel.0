From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 3 Oct 2007 10:58:30 +0100
Subject: Re: LVM2/tools/fsadm Makefile.in
In-Reply-To: <20071003094658.15588.qmail@sourceware.org>
References: <20071003094658.15588.qmail@sourceware.org>
Message-ID: <20071003095830.GH18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 03, 2007 at 09:46:58AM -0000, meyering at sourceware.org wrote:
> 	* tools/fsadm/Makefile.in (LVMLIBS): Define.
> 	(fsadm): Link with $(LVMLIBS).
 
>  fsadm: $(OBJECTS)
> -	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
> +	$(CC) -o $@ $(CFLAGS) $(OBJECTS) $(LDFLAGS) $(LVMLIBS) -rdynamic
  
fsadm is meant to be independent of LVM2 so should not be using LVMLIBS.
What should be done to deal with this?

Alasdair
-- 
agk at redhat.com


