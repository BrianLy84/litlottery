<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lit Lottery | Xổ Số LitVM</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ethers/6.13.0/ethers.umd.min.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --neon: #00ff9d;
            --purple: #9d4edd;
            --dark: #0a0a0f;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0a0a0f 0%, #1a0033 100%);
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }
        header {
            text-align: center;
            padding: 4rem 1rem 2rem;
            background: rgba(0,0,0,0.6);
            border-bottom: 1px solid rgba(0, 255, 157, 0.2);
        }
        h1 {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 3.8rem;
            font-weight: 700;
            background: linear-gradient(90deg, #00ff9d, #9d4edd);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }
        .subtitle {
            font-size: 1.2rem;
            color: #a0a0ff;
            opacity: 0.9;
        }

        .container {
            max-width: 960px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .card {
            background: rgba(20, 20, 35, 0.85);
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            border: 1px solid rgba(0, 255, 157, 0.15);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(12px);
        }

        button {
            background: linear-gradient(90deg, var(--neon), #00cc7a);
            color: #000;
            border: none;
            padding: 16px 32px;
            font-size: 1.15rem;
            font-weight: 600;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 0 20px rgba(0, 255, 157, 0.4);
        }
        button:hover {
            transform: translateY(-4px);
            box-shadow: 0 0 30px rgba(0, 255, 157, 0.6);
        }

        .number-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 14px;
            margin: 25px 0;
        }
        .number-input {
            height: 72px;
            font-size: 1.8rem;
            text-align: center;
            background: #1a1a2e;
            border: 2px solid #333366;
            color: #fff;
            border-radius: 16px;
            transition: all 0.2s;
        }
        .number-input:focus {
            border-color: var(--neon);
            box-shadow: 0 0 15px rgba(0, 255, 157, 0.5);
            outline: none;
        }

        .status {
            margin-top: 1.5rem;
            padding: 1rem 1.5rem;
            background: rgba(0, 255, 157, 0.1);
            border-radius: 12px;
            border-left: 4px solid var(--neon);
        }

        .neon-text {
            text-shadow: 0 0 10px var(--neon);
        }
    </style>
</head>
<body>
    <header>
        <h1 class="neon-text">LIT LOTTERY</h1>
        <p class="subtitle">Xổ số minh bạch • Hàng tuần trên LitVM • 20:00 Thứ Sáu</p>
    </header>

    <div class="container">
        <!-- Kết nối Wallet -->
        <div class="card">
            <h2>1. Kết nối Wallet</h2>
            <button onclick="connectWallet()" style="width: 100%; margin-top: 10px;">KẾT NỐI METAMASK / RABBY</button>
            <p id="walletAddress" style="margin-top: 15px; font-size: 1rem; word-break: break-all; color: #00ff9d;"></p>
        </div>

        <!--