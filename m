From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Jan 2011 13:44:44 +0000
Subject: [PATCH 3/8] Change import_vg_from_buffer to use config_tree
In-Reply-To: <c9446c5e5a74735278f5aae34f72d4947828eb6e.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
	<c9446c5e5a74735278f5aae34f72d4947828eb6e.1294398815.git.zkabelac@redhat.com>
Message-ID: <20110107134444.GD5910@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 07, 2011 at 12:17:31PM +0100, Zdenek Kabelac wrote:
> Change function import_vg_from_buffer() to import_vg_from_config_tree().
> Instead of creating config tree inside the function allow cft to
> be passed as parameter - usable later for caching.
 
Ack.

Alasdair


