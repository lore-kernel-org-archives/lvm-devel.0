Received: from mail-lj1-f177.google.com (mail-lj1-f177.google.com [209.85.208.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F8902FFF80
	for <lvm-devel@lists.linux.dev>; Tue, 23 Dec 2025 06:34:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1766471647; cv=none; b=d14iK73LSMLmMaNYThisOPne2V5ilSv15UXLzTZv2i3p46g8qnuBNCTs190FLEfOouxLrsnCHFg1CskOdP4DfAg1Wov3CCQ8KorHnPijzrdR8xHNqC0AAYj0xSmk9wEoCGNJabZP0cCFZQSQH3KPaQiLX6K35pohcjiCKstkcM4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1766471647; c=relaxed/simple;
	bh=zQMCxWwv+vy2hbOmutXkA1vn5ZNuVRvD6yhOueNtNZU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nflj1T4hzDon7qgr7ulnuLU+G+GgxXMJJuQA2mZQamkjQB/kN5Z2lLEugpbo2HZpxli+Bowhw2YJDvc/O2lWsXILkjQae4w7Xmmy/luSyjQ4B1BSSfbMpz0Fq5Z85kjdWdjDH0bn0Bstr5mNSjjN5dyO7TCwIZDXwpPuYpEV4jI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dfnyrO0H; arc=none smtp.client-ip=209.85.208.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dfnyrO0H"
Received: by mail-lj1-f177.google.com with SMTP id 38308e7fff4ca-37b9728a353so58745001fa.0
        for <lvm-devel@lists.linux.dev>; Mon, 22 Dec 2025 22:34:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1766471644; x=1767076444; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=048jzD37H8lsx/zZlGI/PEx4g5lnBiNM8RokzD3mdsY=;
        b=dfnyrO0H1Nq7ZRPIt2C/vGpxIe4Jz/qAkoW35IgXAd7d1d5PEbRjbqsbDZT4/Krv9F
         kvS6NSixruTPv46NDsUL5Q6XGpFZrNcLYiTXMIjnZoL4FznwLJE1ejAekwHQrFjAdMZ/
         rHzvIC0QUF7Qw9iQSe/8brdCNwgyVXVcZG0TkkYnRDpFAlvWXpGduJL7KrPvt5Ntmian
         I+t3nFf40mHK2RFRUkpjz/uoTztQnQvUIzUgUd0jv29E7NY8mGpZluiCm3i6FCzJFB11
         aQ28h+wNKhDZCLDuXsQxzTrEuFj5RQbgUWCUYgl0sn5sxHVTkKCHxQDOvwmYJZyGrsfH
         dw3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1766471644; x=1767076444;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=048jzD37H8lsx/zZlGI/PEx4g5lnBiNM8RokzD3mdsY=;
        b=OFUlPrN79jkvr37PyLeglWhtLP41mMVrkUJ1pDgY4ZE5TudfjQ2SX2fzX0We+b0zO/
         KsLpEA1wJq1A15P+b2ta72ILw1WLKXr+WwzgEEATzkZ5C1gHFMPjgL7ABDhKFXmouqON
         Q6MwK9r2VTKtj71hT3NfcUIHDASCCDwaPpURf5g/us7p0zQiQZJyZoKImwX12kPkIkvo
         Bap6RrRB3q6mScwPdVDt4IuH8WAQBOYRk0qZosW4TJkDPAxUIMfe+PGYTaIs+eFruT3j
         HUu4RCks2b5FxKkjqDK/2SfqFd4YIAxxe9fcJDMCS1iVwxxd7gJpTT+XaIyOFWT4JwM1
         zJRg==
X-Forwarded-Encrypted: i=1; AJvYcCUIFfO40LuGwtN50XxkeORLRttOVjwwMR3CMLuVdho9BFmiD9H7wP+F8RfF5kVuyPS+5BIq8Pb6IZk=@lists.linux.dev
X-Gm-Message-State: AOJu0Yx/glaQxNIul/6aipvJ0xEjUjwmbEyrydZuo7Otxiina+42Q9Gr
	VX9dkUWbxtM8YNLhZuKop7YbMLpHE+9dm7c55iv+WJ+4ggxmsru7TvDn
X-Gm-Gg: AY/fxX5IZS/a1SCQ4Wl+vPS7F8+6oW5SANX2GCkQGOShIrITyeeZjwbIclaG3Jrcu1H
	BXVaRoTwQthG/e2fQk+L74yvdt+6czjpsNRDwgd3a6Xcf0WlPWzfuxRXLoJYKxlSpoKvAHz5xFb
	GSpEobtYnpjpCKOJGbCmFiFvV6Rhp3zUD8FI60oxcs5wD1qOZ1OKDcn3djR3IniYTjtIvBLt7NL
	VYWUzEVwpP4XJqxqR0n8XrnrQ4bZrcr6Uzupq39gSaoV4+uatYW9gleLBNt7Pj9yWupDtE1oDzR
	RXOunL+aNvoGnhmBLZvprlYZ9kccXjrygSr7C9EG6Lvfuf0KrgUNf2aJIIAp2EkjipI2IdsuO7u
	SA98Pn/pf3GOwmBPgk7+FuYxlIVCtfuutyLJvm364fC/zWfNDIyZ6jqe7R+qHt+W+xcKmok4qcG
	78qOj5RaT5uAgyh3pscNw=
X-Google-Smtp-Source: AGHT+IFaFE0nlDnowk+Ou3U+M9eX56ZCvZ4aEX/mIAF0sQ5oS0z9Fh1vnyWDY8DQIpJC2t19J66zfQ==
X-Received: by 2002:a05:651c:1506:b0:378:e055:3150 with SMTP id 38308e7fff4ca-38121566b66mr43783861fa.5.1766471643890;
        Mon, 22 Dec 2025 22:34:03 -0800 (PST)
Received: from localhost ([194.190.17.114])
        by smtp.gmail.com with UTF8SMTPSA id 38308e7fff4ca-381224de6eesm33742031fa.6.2025.12.22.22.34.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 22 Dec 2025 22:34:03 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: gmazyland@gmail.com
Cc: Dell.Client.Kernel@dell.com,
	dm-devel@lists.linux.dev,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	mpatocka@redhat.com,
	pavel@ucw.cz,
	rafael@kernel.org,
	safinaskar@gmail.com
Subject: Re: [RFC PATCH 2/2] swsusp: make it possible to hibernate to device mapper devices
Date: Tue, 23 Dec 2025 09:33:55 +0300
Message-ID: <20251223063355.2740782-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <86300955-72e4-42d5-892d-f49bdf14441e@gmail.com>
References: <86300955-72e4-42d5-892d-f49bdf14441e@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Milan Broz <gmazyland@gmail.com>:
> Anyway, my understanding is that all device-mapper targets use mempools,
> which should ensure that they can process even under memory pressure.

Okay, I just read some more code and docs.

dm-integrity fortunately uses bufio for checksums only.

And bufio allocates memory without __GFP_IO (thus allocation should not
lead to recursion). And bufio claims that "dm-bufio is resistant to allocation failures":
https://elixir.bootlin.com/linux/v6.19-rc2/source/drivers/md/dm-bufio.c#L1603 .

This still seems to be fragile.

So I will change mode to 'D' and hope for the best. :)

-- 
Askar Safin
