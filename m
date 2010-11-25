From: Petr Rockai <prockai@redhat.com>
Date: Thu, 25 Nov 2010 18:19:26 +0100
Subject: [PATCH 02/29] Fix check for empty system_dir
In-Reply-To: <ced2653c100dd20c1ed531b6ce59ae14a7396b13.1290682013.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Thu, 25 Nov 2010 11:55:06 +0100")
References: <cover.1290682013.git.zkabelac@redhat.com>
	<cover.1290682013.git.zkabelac@redhat.com>
	<ced2653c100dd20c1ed531b6ce59ae14a7396b13.1290682013.git.zkabelac@redhat.com>
Message-ID: <87vd3lmich.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> Fixing most probably a typo - I assume original intention has been
> to check for zero length string.

In that case, please use !strlen(str), as that is much more readable.

> @@ -1036,7 +1036,7 @@ static int _init_backup(struct cmd_context *cmd)
>  	char default_dir[PATH_MAX];
>  	const char *dir;
>
> -	if (!cmd->system_dir) {
> +	if (!*cmd->system_dir) {
>  		log_warn("WARNING: Metadata changes will NOT be backed up");
>  		backup_init(cmd, "", 0);
>  		archive_init(cmd, "", 0, 0, 0);


