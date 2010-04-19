From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 19 Apr 2010 20:38:16 +0200
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c
In-Reply-To: <20100419170628.GE4828@agk-dp.fab.redhat.com>
References: <20100419152225.3141.qmail@sourceware.org>	<4BCC77EC.30005@redhat.com>
	<20100419170628.GE4828@agk-dp.fab.redhat.com>
Message-ID: <4BCCA318.6070803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 19.4.2010 19:06, Alasdair G Kergon wrote:
> On Mon, Apr 19, 2010 at 05:34:04PM +0200, Zdenek Kabelac wrote:
>> Either we should return   const char*  return vg->name;
> 
> But then we have to guarantee that vg->name remains const - which we are
> unable to do.  (We can't impose limits on vgrename.)
> 

I think we may state, that until next call of any lvm library function pointer
remains valid. Thus if user needs it for something later - he needs to make a
local copy.

We may be nicer if we list functions which could change this pointer (i.e. I
wouldn't expect any *_get_* function could ever change it) - but I think it's
not needed - major use case would be to check value for something
and eventually copy somewhere - thus const char* is perfectly usable in this
case. So I think any const char* is valid between lvm calls - and if they are
valid after - it's just pure luck....

Zdenek


