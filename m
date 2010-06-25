From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 07:31:29 -0400
Subject: undefined references in lvm2app
In-Reply-To: <20100625110030.GI14902@agk-dp.fab.redhat.com>
References: <201006241930.49495.benscott@nwlink.com>
	<20100625110030.GI14902@agk-dp.fab.redhat.com>
Message-ID: <1277465489.2472.5.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2010-06-25 at 12:00 +0100, Alasdair G Kergon wrote:
> On Thu, Jun 24, 2010 at 07:30:49PM -0700, ben scott wrote:
> > volgroup.cpp:33: undefined reference to `lvm_vg_get_max_pv'
> > volgroup.cpp:40: undefined reference to `lvm_vg_get_max_lv'
> > volgroup.cpp:48: undefined reference to `lvm_vg_is_exported'
> 
> The liblvm/.exported_symbols file looks to be out-dated:
>  

I'll work on a patch ASAP.


