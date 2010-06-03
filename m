From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 3 Jun 2010 20:51:12 +0100
Subject: [PATCH] fix some issues in clvmd initscript
In-Reply-To: <AANLkTimKDciNUgF1sxYeoZDYLeAmCTqVOUlWtoksj7nr@mail.gmail.com>
References: <4BFD1B92.9080403@redhat.com> <4C07543C.5040908@redhat.com>
	<4C077B2B.5030206@redhat.com> <4C079571.1050409@redhat.com>
	<AANLkTimKDciNUgF1sxYeoZDYLeAmCTqVOUlWtoksj7nr@mail.gmail.com>
Message-ID: <20100603195112.GC30522@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 03, 2010 at 08:31:22PM +0200, brem belguebli wrote:
> started, as it tries to activate all the clustered VG's whether or not
> they're already active  on another node.
 
/etc/sysconfig/clvmd perhaps?


Something like:

# Specifies whether or not to activate clustered LVs after starting up clvmd.
# Note that this file only controls which 'lvchange' commands get run
# and it cannot override lvm.conf.
ACTIVATE=yes

# Space-separated lists of LVs to activate when starting CLVMD.
# Specifying a VG will activate all the LVs within it.

# Clustered LVs activated with "lvchange -aey" on this machine.
# E.g. EXCLUSIVE_LVS="vg1/lvol0 vg1/lvol1 vg2"
EXCLUSIVE_LVS=

# Clustered LVs activated with "lvchange -aly" on this machine.
LOCAL_LVS=

# Clustered LVs activated with "lvchange -ay".
# If all 3 variables (LOCAL_LVS, EXCLUSIVE_LVS & SHARED_LVS) are unset
# or empty and ACTIVATE is "yes" then all clustered LVs visible on the system
# are activated as shared.
SHARED_LVS=


Alasdair


