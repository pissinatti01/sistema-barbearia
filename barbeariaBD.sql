-- =========================================================================
-- BANCO DE DADOS: BARBEARIA DO IGOR VARELA
-- Foco: Gestão de clientes, estoque, fluxo de caixa e agenda (14h às 19h).
-- =========================================================================

DROP DATABASE IF EXISTS BarbeariaDB;
CREATE DATABASE BarbeariaDB;
USE BarbeariaDB;

-- =========================================================================
-- 1. CADASTRO DE CLIENTES
-- =========================================================================

-- Tabela principal do cliente (1FN: Endereço desmembrado para facilitar buscas locais)
CREATE TABLE Cliente (
  idCliente INT UNSIGNED NOT NULL PRIMARY KEY,
  nome VARCHAR(125) NOT NULL,
  logradouro VARCHAR(150) NOT NULL,
  numero VARCHAR(10) NOT NULL,
  bairro VARCHAR(60) NOT NULL,
  cidade VARCHAR(60) NOT NULL,
  uf CHAR(2) NOT NULL,
  cep CHAR(8) NOT NULL
);

-- Contatos do cliente (1FN: Tabela separada para permitir múltiplos telefones)
CREATE TABLE ClienteTelefone (
  idCliente INT UNSIGNED NOT NULL,
  telefone VARCHAR(15) NOT NULL,
  PRIMARY KEY (idCliente, telefone),
  CONSTRAINT fk_cliente_telefone FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente) ON DELETE CASCADE
);

-- =========================================================================
-- 2. TABELAS DE APOIO (ESTOQUE, FINANCEIRO E PREÇOS)
-- =========================================================================

-- Controle do que a barbearia consome e usa
CREATE TABLE Produto (
  idProduto INT UNSIGNED NOT NULL PRIMARY KEY,
  nomeProduto VARCHAR(100) NOT NULL,
  categoria ENUM('Equipamento', 'Consumível') NOT NULL
);

-- Registro de contas a pagar (Água, Luz, etc.)
CREATE TABLE Despesa (
  idDespesa INT UNSIGNED NOT NULL PRIMARY KEY,
  descricao VARCHAR(100) NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  dataReferencia DATE NOT NULL
);

-- Catálogo de serviços e preços base
CREATE TABLE Servico (
  idServico INT UNSIGNED NOT NULL PRIMARY KEY,
  nomeServico VARCHAR(100) NOT NULL,
  precoPadrao DECIMAL(10,2) NOT NULL
);

-- =========================================================================
-- 3. GESTÃO DE AGENDA
-- =========================================================================

-- Cabeçalho do agendamento (Garante a regra de 1 cliente por vez no mesmo horário)
CREATE TABLE Agendamento (
  idAgendamento INT UNSIGNED NOT NULL PRIMARY KEY,
  dataAgendamento DATE NOT NULL,
  horaAgendamento TIME NOT NULL, 
  idCliente INT UNSIGNED NOT NULL,
  
  CONSTRAINT fk_agendamento_cliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
  CONSTRAINT uk_data_hora UNIQUE (dataAgendamento, horaAgendamento)
);

-- Serviços realizados em cada agendamento (2FN: Preço cobrado salvo no histórico)
CREATE TABLE ItemAgendamento (
  idAgendamento INT UNSIGNED NOT NULL,
  idServico INT UNSIGNED NOT NULL,
  precoPraticado DECIMAL(10,2) NOT NULL,
  
  PRIMARY KEY (idAgendamento, idServico),
  CONSTRAINT fk_item_agendamento FOREIGN KEY (idAgendamento) REFERENCES Agendamento(idAgendamento) ON DELETE CASCADE,
  CONSTRAINT fk_item_servico FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);

-- =========================================================================
-- 4. DADOS INICIAIS (TESTE)
-- =========================================================================

INSERT INTO Cliente (idCliente, nome, logradouro, numero, bairro, cidade, uf, cep) VALUES
(1, 'Marcos Paulo', 'Av. Maria Lacerda Montenegro', '100', 'Nova Parnamirim', 'Parnamirim', 'RN', '59152600'),
(2, 'Felipe Alves', 'Rua Carmem Miranda', '45', 'Nova Parnamirim', 'Parnamirim', 'RN', '59152000');

INSERT INTO ClienteTelefone (idCliente, telefone) VALUES
(1, '84999991111'),
(2, '84988882222'),
(2, '84977773333');

INSERT INTO Servico (idServico, nomeServico, precoPadrao) VALUES
(10, 'Corte Low Fade', 30.00),
(11, 'Corte Mid Fade', 30.00),
(12, 'Corte Wolf Cut', 30.00),
(13, 'Corte Americano', 30.00),
(14, 'Corte Social', 30.00),
(20, 'Pintura', 40.00),
(21, 'Descoloração Completa', 60.00);

INSERT INTO Produto (idProduto, nomeProduto, categoria) VALUES
(1, 'Tesoura', 'Equipamento'),
(2, 'Escova', 'Equipamento'),
(3, 'Talco', 'Consumível'),
(4, 'Gel em Pó', 'Consumível'),
(5, 'Tinta', 'Consumível'),
(6, 'Descolorante de Cabelo', 'Consumível');

INSERT INTO Despesa (idDespesa, descricao, valor, dataReferencia) VALUES
(1, 'Conta de Luz', 185.50, '2026-11-05'),
(2, 'Conta de Água', 75.00, '2026-11-05');

-- Agendamentos da semana (entre 14h e 19h)
INSERT INTO Agendamento (idAgendamento, dataAgendamento, horaAgendamento, idCliente) VALUES
(1001, '2026-11-06', '14:00:00', 1),
(1002, '2026-11-06', '15:00:00', 2),
(1003, '2026-11-07', '18:00:00', 1);

INSERT INTO ItemAgendamento (idAgendamento, idServico, precoPraticado) VALUES
(1001, 10, 30.00),
(1002, 13, 30.00),
(1002, 20, 40.00),
(1003, 14, 30.00);

-- =========================================================================
-- 5. RELATÓRIOS E CONSULTAS DE GESTÃO
-- =========================================================================

-- Agenda do Dia (Ex: 06/11/2026)
SELECT 
    a.horaAgendamento AS 'Horário',
    c.nome AS 'Cliente',
    s.nomeServico AS 'Serviço',
    i.precoPraticado AS 'Valor Cobrado'
FROM Agendamento a
INNER JOIN Cliente c ON a.idCliente = c.idCliente
INNER JOIN ItemAgendamento i ON a.idAgendamento = i.idAgendamento
INNER JOIN Servico s ON i.idServico = s.idServico
WHERE a.dataAgendamento = '2026-11-06'
ORDER BY a.horaAgendamento;

-- Balanço Financeiro (Faturamento Previsto vs Despesas)
SELECT 
    (SELECT SUM(valor) FROM Despesa) AS 'Total Despesas',
    (SELECT SUM(precoPraticado) FROM ItemAgendamento) AS 'Faturamento Previsto',
    ((SELECT SUM(precoPraticado) FROM ItemAgendamento) - (SELECT SUM(valor) FROM Despesa)) AS 'Lucro Liquido'
FROM DUAL;

-- Visão Geral do Estoque
SELECT 
    categoria AS 'Tipo',
    COUNT(idProduto) AS 'Qtd de Itens',
    GROUP_CONCAT(nomeProduto SEPARATOR ', ') AS 'Lista de Itens'
FROM Produto
GROUP BY categoria;
