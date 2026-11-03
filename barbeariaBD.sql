-- 1. Tabela de Usuários (Clientes, Barbeiro/Administrador)
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    tipo ENUM('cliente', 'barbeiro') DEFAULT 'cliente',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Serviços (Cortes, Pinturas, etc.)
CREATE TABLE servicos (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Low Fade', 'Wolf Cut', 'Pintura', 'Descoloração'
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL DEFAULT 30.00,
    duracao_minutos INT NOT NULL DEFAULT 60 -- Garante 1 cliente por vez a cada intervalo
);

-- 3. Tabela de Agendamentos (Reservas do Cliente)
CREATE TABLE agendamentos (
    id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_servico INT NOT NULL,
    data_agendamento DATE NOT NULL,
    horario_inicio TIME NOT NULL, -- Restrito ao horário das 14:00 às 19:00
    status ENUM('agendado', 'concluido', 'cancelado') DEFAULT 'agendado',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_servico) REFERENCES servicos(id_servico),
    CONSTRAINT chk_horario CHECK (horario_inicio >= '14:00:00' AND horario_inicio < '19:00:00')
);

-- 4. Tabela de Produtos / Controle de Estoque
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Tesoura', 'Talco', 'Escova', 'Tinta', 'Gel em pó', 'Descolorante'
    quantidade_estoque INT NOT NULL DEFAULT 0,
    preco_custo DECIMAL(10, 2) NOT NULL,
    unidade_medida VARCHAR(20) DEFAULT 'unidade' -- Ex: 'unidade', 'pote', 'frasco'
);

-- 5. Tabela de Compras de Produtos (Entrada no Estoque)
CREATE TABLE compras_produtos (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    data_compra DATE NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- 6. Tabela de Despesas Fixas e Variáveis (Contas da Barbearia)
CREATE TABLE despesas (
    id_despesa INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL, -- Ex: 'Conta de Luz', 'Conta de Água'
    valor DECIMAL(10, 2) NOT NULL,
    data_vencimento DATE NOT NULL,
    status_pagamento ENUM('pendente', 'pago') DEFAULT 'pendente'
);

-- 7. Tabela de Registro Financeiro / Entradas de Dinheiro
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_agendamento INT NOT NULL,
    valor_pago DECIMAL(10, 2) NOT NULL DEFAULT 30.00,
    forma_pagamento ENUM('dinheiro', 'pix', 'cartao_credito', 'cartao_debito') NOT NULL,
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id_agendamento)
);
