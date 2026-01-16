-- =====================================================
-- SOPORTE PARA MÚLTIPLES CLIENTES POR MESA
-- =====================================================
-- Permite que una mesa tenga múltiples ventas PENDIENTES (una por cliente)
-- La mesa se libera solo cuando TODAS las ventas están completadas/canceladas

-- Modificar trigger para manejar múltiples clientes por mesa
CREATE OR REPLACE FUNCTION actualizar_estado_mesa()
RETURNS TRIGGER AS $$
DECLARE
    ventas_pendientes INT;
    mesa_objetivo UUID;
BEGIN
    -- Determinar qué mesa verificar
    IF TG_OP = 'DELETE' THEN
        mesa_objetivo := OLD.mesa_id;
    ELSE
        mesa_objetivo := NEW.mesa_id;
        -- También verificar la mesa anterior si cambió
        IF TG_OP = 'UPDATE' AND OLD.mesa_id IS DISTINCT FROM NEW.mesa_id AND OLD.mesa_id IS NOT NULL THEN
            SELECT COUNT(*) INTO ventas_pendientes 
            FROM ventas 
            WHERE mesa_id = OLD.mesa_id AND estado = 'PENDIENTE';
            
            IF ventas_pendientes > 0 THEN
                UPDATE mesas SET estado = 'OCUPADA' WHERE id = OLD.mesa_id;
            ELSE
                UPDATE mesas SET estado = 'LIBRE' WHERE id = OLD.mesa_id;
            END IF;
        END IF;
    END IF;
    
    -- Verificar mesa objetivo
    IF mesa_objetivo IS NOT NULL THEN
        SELECT COUNT(*) INTO ventas_pendientes 
        FROM ventas 
        WHERE mesa_id = mesa_objetivo AND estado = 'PENDIENTE';
        
        IF ventas_pendientes > 0 THEN
            UPDATE mesas SET estado = 'OCUPADA' WHERE id = mesa_objetivo;
        ELSE
            UPDATE mesas SET estado = 'LIBRE' WHERE id = mesa_objetivo;
        END IF;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Recrear trigger
DROP TRIGGER IF EXISTS trigger_estado_mesa ON ventas;
CREATE TRIGGER trigger_estado_mesa
AFTER INSERT OR UPDATE OR DELETE ON ventas
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_mesa();
