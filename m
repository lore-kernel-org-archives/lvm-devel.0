From: Milan Broz <mbroz@redhat.com>
Date: Wed, 05 Jan 2011 01:57:25 +0100
Subject: [PATCH 04/23] Remove dead assignment of lock_flags
In-Reply-To: <20110105003002.GG10297@agk-dp.fab.redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<0662c43178e50334f41961cbb83743e9eb7e5e53.1292945707.git.zkabelac@redhat.com>
	<4D10D3B3.1070003@redhat.com> <4D11CED8.2070204@redhat.com>
	<20110105003002.GG10297@agk-dp.fab.redhat.com>
Message-ID: <4D23C1F5.90101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/05/2011 01:30 AM, Alasdair G Kergon wrote:
> On Wed, Dec 22, 2010 at 11:11:36AM +0100, Zdenek Kabelac wrote:
>> I always thought that's why /* comments */  were invented ;) for things like
>> this, but anyway in this case if you prefer to keep the unused value present -
>> I'll hide it only for my local scan-builds :)
>  
> So do a patch that moves it into a comment?

That code is messy, and it should be cleaned - the lock_vg() name is misleading
(it should be called pre_lock_vg(), it should take pre-parsed flags and not parse
it itself from client struct - the same like lock_lv etc)

So if you think cleaning one variable help anything, better do it than spent another
week discussing it :-)

Milan


