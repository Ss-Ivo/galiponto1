/*
  # Sistema de Gerenciamento de Galinhas - Schema Completo

  1. New Tables
    - `galinhas`
      - `id` (uuid, primary key)
      - `numero_identificacao` (text, unique)
      - `data_entrada` (date)
      - `raca` (text)
      - `idade_entrada` (integer - em semanas)
      - `origem` (text)
      - `ativa` (boolean, default true)
      - `created_at` (timestamp)

    - `saidas_galinhas`
      - `id` (uuid, primary key)
      - `galinha_id` (uuid, foreign key)
      - `data_saida` (date)
      - `motivo` (text)
      - `observacoes` (text)
      - `created_at` (timestamp)

    - `producao_ovos`
      - `id` (uuid, primary key)
      - `data` (date)
      - `quantidade` (integer)
      - `galinhas_produtoras` (text array)
      - `observacoes` (text)
      - `created_at` (timestamp)

    - `alimentacao`
      - `id` (uuid, primary key)
      - `data` (date)
      - `tipo_racao` (text)
      - `quantidade_kg` (decimal)
      - `custo` (decimal)
      - `observacoes` (text)
      - `created_at` (timestamp)

    - `saude`
      - `id` (uuid, primary key)
      - `galinha_id` (uuid, foreign key)
      - `data` (date)
      - `tipo` (text - vacina, doenca, tratamento)
      - `descricao` (text)
      - `custo` (decimal)
      - `observacoes` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their data
*/

-- Tabela de galinhas
CREATE TABLE IF NOT EXISTS galinhas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero_identificacao text UNIQUE NOT NULL,
  data_entrada date NOT NULL,
  raca text NOT NULL,
  idade_entrada integer NOT NULL,
  origem text NOT NULL,
  ativa boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Tabela de saídas de galinhas
CREATE TABLE IF NOT EXISTS saidas_galinhas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  galinha_id uuid REFERENCES galinhas(id) ON DELETE CASCADE,
  data_saida date NOT NULL,
  motivo text NOT NULL,
  observacoes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Tabela de produção de ovos
CREATE TABLE IF NOT EXISTS producao_ovos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  data date NOT NULL,
  quantidade integer NOT NULL,
  galinhas_produtoras text[] DEFAULT '{}',
  observacoes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Tabela de alimentação
CREATE TABLE IF NOT EXISTS alimentacao (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  data date NOT NULL,
  tipo_racao text NOT NULL,
  quantidade_kg decimal(10,2) NOT NULL,
  custo decimal(10,2) NOT NULL,
  observacoes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Tabela de saúde
CREATE TABLE IF NOT EXISTS saude (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  galinha_id uuid REFERENCES galinhas(id) ON DELETE CASCADE,
  data date NOT NULL,
  tipo text NOT NULL CHECK (tipo IN ('vacina', 'doenca', 'tratamento')),
  descricao text NOT NULL,
  custo decimal(10,2) DEFAULT 0,
  observacoes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE galinhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE saidas_galinhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE producao_ovos ENABLE ROW LEVEL SECURITY;
ALTER TABLE alimentacao ENABLE ROW LEVEL SECURITY;
ALTER TABLE saude ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Users can manage galinhas"
  ON galinhas
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Users can manage saidas_galinhas"
  ON saidas_galinhas
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Users can manage producao_ovos"
  ON producao_ovos
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Users can manage alimentacao"
  ON alimentacao
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Users can manage saude"
  ON saude
  FOR ALL
  TO authenticated
  USING (true);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_galinhas_ativa ON galinhas(ativa);
CREATE INDEX IF NOT EXISTS idx_producao_ovos_data ON producao_ovos(data);
CREATE INDEX IF NOT EXISTS idx_alimentacao_data ON alimentacao(data);
CREATE INDEX IF NOT EXISTS idx_saude_galinha_id ON saude(galinha_id);
CREATE INDEX IF NOT EXISTS idx_saude_data ON saude(data);