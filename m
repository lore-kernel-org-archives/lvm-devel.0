From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 18 Mar 2010 13:39:33 +0000
Subject: [PATCH 01/25] Remove const from volume_group* in process_each
In-Reply-To: <6a34f3f1453baa96dfac7024ddfedb2034ba32a0.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
	<6a34f3f1453baa96dfac7024ddfedb2034ba32a0.1268833246.git.zkabelac@redhat.com>
Message-ID: <20100318133933.GF17615@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 17, 2010 at 02:46:54PM +0100, Zdenek Kabelac wrote:
> struct volume_group could change as a result of process_single()
> so vg is not const.
 
Ack.

Alasdair


