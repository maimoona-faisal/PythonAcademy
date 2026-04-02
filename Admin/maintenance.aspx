<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="maintenance.aspx.cs" Inherits="PythonAcademy.Admin.WebForm1" %>

<!DOCTYPE html>
<html>
<head>
    <title>System Maintenance - Python Academy</title>
    <style>
        body {
            background-color: #0a0f1e;
            color: #ffffff;
            font-family: 'Consolas', 'Courier New', monospace; 
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .terminal-box {
            text-align: left; 
            border-left: 3px solid #f5a623;
            padding-left: 20px;
        }
        h1 {
            color: #f5a623;
            font-size: 2rem;
            margin-top: 0;
            font-weight: normal;
            letter-spacing: 1px;
        }
        p {
            font-size: 1.1rem;
            color: #a9b8d6;
            margin: 8px 0;
        }
        .blink {
            animation: blinker 1s step-end infinite;
            color: #f5a623;
        }
        @keyframes blinker {
            50% { opacity: 0; }
        }
    </style>
</head>
<body>
    <div class="terminal-box">
        <h1>&#9881; SYSTEM_MAINTENANCE<span class="blink">_</span></h1>
        
        <p>> Python Academy is temporarily down for server upgrades.</p>
        <p>> Please check back soon.</p>
    </div>
</body>
</html>