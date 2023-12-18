Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 869B820DD7
	for <lvm-devel@lists.linux.dev>; Mon, 18 Dec 2023 11:55:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="cMkGbPRi"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1702900551;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type;
	bh=ghXa+8UI/zsfO2+Q3Iki0Zvdfrta4LI7dWPVrDkCdIA=;
	b=cMkGbPRian8ugu9VOu5D6dE82eeSImhQHH8xgPi9rz3VDs0k2Y1Hb7oWZwdaYstpheEETs
	94buCT23I2m6CCglMur+rYKLiMlXBJAMK7SGuvV6/d3XH6ryya4K0shaEQQ4F5dcZYkno7
	1Tdy4V5rd+RA+/8B0INVTtpItkR8LLk=
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com
 [209.85.218.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-59-zWjNVvF4MoCbR092WFwrRA-1; Mon, 18 Dec 2023 06:55:50 -0500
X-MC-Unique: zWjNVvF4MoCbR092WFwrRA-1
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-9fd0a58549bso313060266b.0
        for <lvm-devel@lists.linux.dev>; Mon, 18 Dec 2023 03:55:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1702900548; x=1703505348;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=ghXa+8UI/zsfO2+Q3Iki0Zvdfrta4LI7dWPVrDkCdIA=;
        b=W6ARc1+DvKq/WvzdXd1aFp2aaAwWuCEHAnVu5rE723HAZ+coxIXNuakG3AAWrlwoJw
         9vzVsSVfLEqr/ETJGPGC32+pO+a4pfis0EmJk5zA4Xbr25Gjp5dfFiWPCTWbGzc8GVuQ
         GE9LguXeVJLFm7SAKdXTZ6T5K34Nsz2gLFIj0SVPcf5vNGNT1e5knt7b4ZBlQ8O9/skW
         LNT4/x8Pcb2VCx6m8hF4lvwUjtp0EZseH01j9Wo3fXtbSnr2446tkbzso4B9SxPgJrqe
         gu8Hwtpii7Ld/wUMp45B1ZIeZnSIROpziDmYiYLobZQbO4nVHzZBNAPWWcx1tDUoX+R4
         CbAg==
X-Gm-Message-State: AOJu0YylCwfpDsaZxEwFZwEJimgsU5A8Us1XpKWUQamTbZxfPPuQkAGk
	vRJGLOhtUAqhU5q9dYcw6KZkbzDL1Qx7+opCWnnj8M2SbMeb1I9l0/CrY6gvY9QDwZj8LleM9X2
	AK0mVyCYsKh3PYX5UAAv1egFH8GevHXUBU5XkHyVxXwigwFU=
X-Received: by 2002:a17:907:60d0:b0:a1c:ab29:87e2 with SMTP id hv16-20020a17090760d000b00a1cab2987e2mr18267710ejc.35.1702900548539;
        Mon, 18 Dec 2023 03:55:48 -0800 (PST)
X-Google-Smtp-Source: AGHT+IH1lC12fbB8EBQN5k/nS4774KUXuhgmpktBkoN419KQsw8JBvAMbUDfjzR61FzfnuXMUNzC+2WjXo9JzCuz438=
X-Received: by 2002:a17:907:60d0:b0:a1c:ab29:87e2 with SMTP id
 hv16-20020a17090760d000b00a1cab2987e2mr18267704ejc.35.1702900548228; Mon, 18
 Dec 2023 03:55:48 -0800 (PST)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Ranjith ML <rmadhuso@redhat.com>
Date: Mon, 18 Dec 2023 17:25:31 +0530
Message-ID: <CAGEzBDznnrBNrVKeLNEZrb6TQ-SvrJDAdRRQ1FDatcsX8bf4MA@mail.gmail.com>
Subject: VG metadata file names appear twice while executing "vgcfgrestore"
To: lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"

Hi,

VG metadata file names appear twice while executing "vgcfgrestore" and
this patch fixes it by removing duplicate file name.

The modification in this patch updates the logging VG metadata file
name in the _display_archive function to print only the file path
(path) without including the additional file name (af->name).

---
$ cat 0118-vgcfgrestore.patch
diff -Nurp LVM2.2.03.14.org/lib/format_text/archive.c
LVM2.2.03.14/lib/format_text/archive.c
--- LVM2.2.03.14.org/lib/format_text/archive.c  2021-10-20
15:55:05.000000000 +0530
+++ LVM2.2.03.14/lib/format_text/archive.c  2023-12-14 00:56:16.108721142 +0530
@@ -313,7 +313,7 @@ static void _display_archive(struct cmd_
  }

  log_print(" ");
- log_print("File:\t\t%s/%s", path, af->name);
+ log_print("File:\t\t%s", path);
  tc.path_live = path;

  fic.type = FMT_INSTANCE_PRIVATE_MDAS;
---

Without the fix, vgcfgrestore incorrectly prints the VG metadata file path.

---
# vgcfgrestore -l rhel

  File:   /etc/lvm/archive/rhel_00000-1376411295.vg/rhel_00000-1376411295.vg
  <====
  VG name:      rhel
  Description:  Created *before* executing 'pvscan --cache --activate ay 252:2'
  Backup Time:  Wed Jul 19 15:44:51 2023


  File:   /etc/lvm/backup/rhel/rhel
  VG name:      rhel
  Description:  Created *after* executing 'pvscan --cache --activate ay 252:2'
  Backup Time:  Wed Jul 19 15:44:51 2023
---

With this fix, it prints correctly.

---
# vgcfgrestore -l rhel

  File:   /etc/lvm/archive/rhel_00000-1376411295.vg
  VG name:      rhel
  Description:  Created *before* executing 'pvscan --cache --activate ay 252:2'
  Backup Time:  Wed Jul 19 15:44:51 2023


  File:   /etc/lvm/backup/rhel
  VG name:      rhel
  Description:  Created *after* executing 'pvscan --cache --activate ay 252:2'
  Backup Time:  Wed Jul 19 15:44:51 2023
---

Regards,
Ranjith

