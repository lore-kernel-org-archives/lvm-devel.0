Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2376C18DB13
	for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 16:48:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740502105; cv=none; b=lvH7AQSSMghimtl1x7fWClTDfRui3APyQILeMyqCDlHj+0eifoLONVc1Dste6rPotjIXJRg2zIUKuPTRhCMTgOq1DTGhfAZuk473hxm8IGdq5adofBCLCcv3yE2yxaWp915EnygOlCJo0xO1GI50Ascpu7O2Sk00UYDxpRiPa8E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740502105; c=relaxed/simple;
	bh=J1m8+BXAOJ60wgqvlBoD8zJTbMkFzpK5zazIevdiUDw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=W6elMiLPDPlAwPUUuBA+VBOXlryJwEYnLeylzv8XbtBUZIK1HUid5++iRuAtmT4yCV8XlThmzR/pIH8F6ooiK87ZfEFWyw0f+NXFvgFGMSntIhY9oG0f5NV2O5WdnCAKTzbyYwecSiQQsnS79P7lNHHLH26LxqffU0iYG7qS+74=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Q2i2SvbU; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Q2i2SvbU"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1740502103;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=Thy9mI6t6erxvxTMm39DvJ/Ed3aQzQNaWdaHzyYX1Mg=;
	b=Q2i2SvbUaEeLP30G/nS8xyFbqDm1q2Iua1nlYGuANCSxaiFTnhLf9eiqHbhZjHEceuurch
	XQ2cVsny23FUEgsyula1IEl698HZuS0eSs4RF1EUM5y3sqW1bWrxhz4C6aKDhSwfK45G0U
	a+zqU8uNFlvzB7ZcNmSRz/Eje3j/A1Y=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-382-R-pM6DwfMb6s5tVVug9aXA-1; Tue,
 25 Feb 2025 11:48:09 -0500
X-MC-Unique: R-pM6DwfMb6s5tVVug9aXA-1
X-Mimecast-MFC-AGG-ID: R-pM6DwfMb6s5tVVug9aXA_1740502089
Received: from mx-prod-int-02.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-02.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 080F41800875;
	Tue, 25 Feb 2025 16:48:09 +0000 (UTC)
Received: from redhat.com (unknown [10.22.64.219])
	by mx-prod-int-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 1C50819560AE;
	Tue, 25 Feb 2025 16:48:07 +0000 (UTC)
Date: Tue, 25 Feb 2025 10:48:05 -0600
From: David Teigland <teigland@redhat.com>
To: SCOTT FIELDS <Scott.Fields@kyndryl.com>
Cc: "lvm-devel@lists.linux.dev" <lvm-devel@lists.linux.dev>
Subject: Re: Migration of disks within a clustered LVM2 volume group
Message-ID: <Z730RQzVWMmJmwoG@redhat.com>
References: <BYAPR14MB2967BDF2FF9A5B29E90D09A68AC32@BYAPR14MB2967.namprd14.prod.outlook.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <BYAPR14MB2967BDF2FF9A5B29E90D09A68AC32@BYAPR14MB2967.namprd14.prod.outlook.com>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.15
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: WCTw-bH9GPaBqT4oV1iYeVYmtvynnlV9A_X2gFF8bac_1740502089
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 25, 2025 at 12:01:30PM +0000, SCOTT FIELDS wrote:
> It has been stated that mirroring is deprecated in clustered LVM2 configurations and currently unsupported.
> 
> To migrate a physical volume to a new physical volume requires the volume group to be brought into a non-clustered state to perform the migration. Afterwards, it can be brought back into a clustered state, post migration.
> 
> Is there any alternative, since doing so is disruptive twice, and counter to it being a clustered system.

Hi, you can move each LV that is using the given PV, e.g.

$ pvs
  PV           VG Fmt  Attr PSize    PFree   
  /dev/nvme0n1 vg lvm2 a--  1020.00m  732.00m
  /dev/nvme1n1 vg lvm2 a--  1020.00m 1020.00m
  /dev/nvme2n1 vg lvm2 a--  1020.00m  988.00m
  /dev/nvme3n1 vg lvm2 a--  1020.00m 1020.00m

$ pvmove /dev/nvme2n1 /dev/nvme3n1
  pvmove in a shared VG requires a named LV.

$ lvs -o+devices vg
  LV VG Attr       LSize  Devices                         
  lv vg -wi-a----- 64.00m /dev/nvme0n1(64),/dev/nvme2n1(0)

$ pvmove -n lv /dev/nvme2n1 /dev/nvme3n1
  /dev/nvme2n1: Moved: 100.00%

$ lvs -o+devices vg
  LV       VG Attr       LSize  Devices                         
  lv vg -wi-a----- 64.00m /dev/nvme0n1(64),/dev/nvme3n1(0)

