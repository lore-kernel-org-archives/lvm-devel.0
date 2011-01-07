From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Jan 2011 13:41:41 +0000
Subject: [PATCH 2/8] Add default error path for get_property
In-Reply-To: <6bbe3896c9173603df3be06a3e60dd79f339e028.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
	<6bbe3896c9173603df3be06a3e60dd79f339e028.1294398815.git.zkabelac@redhat.com>
Message-ID: <20110107134141.GC5910@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 07, 2011 at 12:17:30PM +0100, Zdenek Kabelac wrote:
> +			log_errno(EINVAL, "Invalid query for property.");

Do we have any information about the property to include in that error
message, such as its name?

Ack.

Alasdair


