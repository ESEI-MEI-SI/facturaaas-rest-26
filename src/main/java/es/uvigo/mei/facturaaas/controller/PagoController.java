package es.uvigo.mei.facturaaas.controller;

import es.uvigo.mei.facturaaas.dto.PagoDTO;
import es.uvigo.mei.facturaaas.model.Pago;
import es.uvigo.mei.facturaaas.service.PagoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/pagos")
public class PagoController {
    
    @Autowired
    private PagoService pagoService;
    
    @GetMapping
    public ResponseEntity<List<PagoDTO>> listar(
            @RequestParam(required = false) Long usuarioId,
            @RequestParam(required = false) Long clienteId) {
        if (usuarioId != null && clienteId != null) {
            return ResponseEntity.ok(pagoService.obtenerPorUsuarioYCliente(usuarioId, clienteId));
        } else if (usuarioId != null) {
            return ResponseEntity.ok(pagoService.obtenerPorUsuario(usuarioId));
        }
        return ResponseEntity.badRequest().build();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<PagoDTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(pagoService.obtenerPorId(id));
    }
    
    @PatchMapping("/{id}/estado")
    public ResponseEntity<PagoDTO> actualizarEstado(
            @PathVariable Long id,
            @RequestParam Pago.EstadoPago estado) {
        return ResponseEntity.ok(pagoService.actualizarEstado(id, estado));
    }
}
