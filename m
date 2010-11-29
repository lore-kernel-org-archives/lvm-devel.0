From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:51:45 +0000
Subject: [PATCH 21/29] Instrument with nonnull dev_manager_transient
In-Reply-To: <5f41ba3ce7405e6049ead308613062eae67e4171.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5f41ba3ce7405e6049ead308613062eae67e4171.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129215145.GP29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:25AM +0100, Zdenek Kabelac wrote:
> +int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));

Ack.

Alasdair


