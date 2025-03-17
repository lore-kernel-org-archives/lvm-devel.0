Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04FCE8F5C
	for <lvm-devel@lists.linux.dev>; Mon, 17 Mar 2025 07:51:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1742197906; cv=none; b=R+PN2DWmJXE5X/OlGjh/G568JOY3nftucehlOe6XjWWLA6FdKPUHd6ZgtPSEhiZzHO1Wd388NZZx9toLxzvz7NnqQDWOT6/bZSnBwMdIFKMkClpnVDMHp4nulMBNE05HrrpCBGpRD9LRM/EQEqE68dRZVFFyHwc1DroLLeJuNe0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1742197906; c=relaxed/simple;
	bh=Xae8yS1diLLAU09iEbOKOMsSJ0laZ23SGEi2EvQilTU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:content-type; b=RnEFesluZiluUniCfoWP1tRwK/espE2TNwyvqlehOAziH6o6l7NneU7wPhDDyWo/TUjdZW7x5OwlcH+OMgdkcA3/sJ1mXkKR+Pc0IW7eAqJ5VrsNa0ysHS7SlTYk/xOwyuMarmA7fVNfPZVSiAkokwJ8SedC+cjj2iEuz+cVtfU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=i1Z8OASR; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="i1Z8OASR"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1742197902;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=6i+Sz1Smg0qZtPZKX9wSH3R19ZTR6i5mZbO6zcvW8pw=;
	b=i1Z8OASRiPQlDtYaSp7kXaUdtkiFZmqItAaMOwQOGAc7AiD4KT1+SRzu9tsVgdkCS7Ncy+
	XqggYW0xQspR8NFvfb3b+ydpLlv/28owrWsnbfNXU5dgj65RGhZXH2ZsQRo3Hu4FlaOMjo
	S5tsOfcZBJho/kiqSxbHVz5ToCGxGoI=
Received: from mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-214-ITk2fpYrNHKAfBBuFX1R0w-1; Mon,
 17 Mar 2025 03:51:41 -0400
X-MC-Unique: ITk2fpYrNHKAfBBuFX1R0w-1
X-Mimecast-MFC-AGG-ID: ITk2fpYrNHKAfBBuFX1R0w_1742197900
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 16DF4195609E
	for <lvm-devel@lists.linux.dev>; Mon, 17 Mar 2025 07:51:40 +0000 (UTC)
Received: from thinkpad.redhat.com (unknown [10.64.240.119])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 65B401955DCD;
	Mon, 17 Mar 2025 07:51:36 +0000 (UTC)
From: Ming-Hung Tsai <mtsai@redhat.com>
To: lvm-devel@lists.linux.dev
Cc: zkabelac@redhat.com,
	Ming-Hung Tsai <mtsai@redhat.com>
Subject: [PATCH 1/2] config: fix value trunction when reading int64 configurations
Date: Mon, 17 Mar 2025 15:51:24 +0800
Message-ID: <20250317075125.840941-1-mtsai@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: KvKSDCNW0c3pLjp3pOKRtNYNIhxELtIJduQPdMRDKm8_1742197900
X-Mimecast-Originator: redhat.com
Content-Transfer-Encoding: 8bit
content-type: text/plain; charset="US-ASCII"; x-default=true

Use int64_t to prevent truncation of the parsed value.

Signed-off-by: Ming-Hung Tsai <mtsai@redhat.com>
---
 lib/config/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 53d6fc9a06ca..9df9c925c152 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1372,7 +1372,7 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	const cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
 	int profile_applied;
-	int i64;
+	int64_t i64;
 
 	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
-- 
2.47.0

