From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Oct 2010 14:45:36 +0200
Subject: [PATCH] lvconvert: provide useful error when snapshot-merge target missing
In-Reply-To: <20101014112426.GD32395@agk-dp.fab.redhat.com>
References: <20101013185302.GA2944@redhat.com>
	<4CB6034D.5080603@redhat.com>	<20101013214257.GC32395@agk-dp.fab.redhat.com>	<4CB6C782.6020501@redhat.com>
	<20101014112426.GD32395@agk-dp.fab.redhat.com>
Message-ID: <4CB6FB70.8030501@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.10.2010 13:24, Alasdair G Kergon napsal(a):
> On Thu, Oct 14, 2010 at 11:04:02AM +0200, Zdenek Kabelac wrote:
>> I'd propose to drop/turn off this feature completely - targets usually cannot
>> work without heavy tweaking through the rest of the code anyway. So in fact we
>> rather 'pretend' there is such functionality.
> 
> The reason for the shared libraries is so that a distro can ship support
> for older formats like LVM1 or pool but people who know they don't need
> it don't have to have it loaded it all the time.
> 

Those object files take like 30KB and we are memory locking a lot of MB of
various glibc and other libs wasteful code...

The main problem I can see is - that things like support of snapshot are not
concentrated in one little object file - but in a lot of other places. So we
do not have clean enough border for this API.

And in effect we would actually consume quite few KB more in case those libs
would be used dynamically and while we extend lvm library with user API - we
actually waste probably far more space - which is not commonly needed.

Zdenek


