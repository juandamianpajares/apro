import { useState, useCallback } from "react";
import axios, { AxiosError, AxiosRequestConfig } from "axios";

/**
 * Estado de la API request
 */
interface ApiState<T> {
  data: T | null;
  error: string | null;
  loading: boolean;
}

/**
 * Opciones para el hook useApi
 */
interface UseApiOptions<T> {
  onSuccess?: (data: T) => void;
  onError?: (error: string) => void;
  initialData?: T | null;
}

/**
 * Hook personalizado para manejar llamadas a API
 *
 * @example
 * ```tsx
 * const { data, loading, error, execute } = useApi<Product[]>({
 *   onSuccess: (products) => console.log('Productos cargados:', products),
 *   onError: (error) => console.error('Error:', error)
 * });
 *
 * // Ejecutar request
 * await execute('/api/products', { method: 'GET' });
 * ```
 */
export function useApi<T = any>(options?: UseApiOptions<T>) {
  const [state, setState] = useState<ApiState<T>>({
    data: options?.initialData || null,
    error: null,
    loading: false,
  });

  /**
   * Ejecuta una llamada a la API
   */
  const execute = useCallback(
    async (url: string, config?: AxiosRequestConfig) => {
      setState((prev) => ({ ...prev, loading: true, error: null }));

      try {
        const response = await axios<T>(url, {
          ...config,
          baseURL: config?.baseURL || process.env.NEXT_PUBLIC_API_URL || "",
        });

        setState({
          data: response.data,
          error: null,
          loading: false,
        });

        options?.onSuccess?.(response.data);
        return response.data;
      } catch (err) {
        const error = err as AxiosError<{ message?: string }>;
        const errorMessage =
          error.response?.data?.message ||
          error.message ||
          "Ha ocurrido un error";

        setState({
          data: null,
          error: errorMessage,
          loading: false,
        });

        options?.onError?.(errorMessage);
        throw error;
      }
    },
    [options]
  );

  /**
   * Reset del estado
   */
  const reset = useCallback(() => {
    setState({
      data: options?.initialData || null,
      error: null,
      loading: false,
    });
  }, [options?.initialData]);

  return {
    data: state.data,
    error: state.error,
    loading: state.loading,
    execute,
    reset,
  };
}

/**
 * Hook para GET requests
 */
export function useGet<T = any>(url: string, options?: UseApiOptions<T>) {
  const api = useApi<T>(options);

  const get = useCallback(
    (params?: Record<string, any>) => {
      return api.execute(url, {
        method: "GET",
        params,
      });
    },
    [url, api]
  );

  return { ...api, get };
}

/**
 * Hook para POST requests
 */
export function usePost<T = any, D = any>(
  url: string,
  options?: UseApiOptions<T>
) {
  const api = useApi<T>(options);

  const post = useCallback(
    (data?: D) => {
      return api.execute(url, {
        method: "POST",
        data,
      });
    },
    [url, api]
  );

  return { ...api, post };
}

/**
 * Hook para PUT requests
 */
export function usePut<T = any, D = any>(
  url: string,
  options?: UseApiOptions<T>
) {
  const api = useApi<T>(options);

  const put = useCallback(
    (data?: D) => {
      return api.execute(url, {
        method: "PUT",
        data,
      });
    },
    [url, api]
  );

  return { ...api, put };
}

/**
 * Hook para DELETE requests
 */
export function useDelete<T = any>(url: string, options?: UseApiOptions<T>) {
  const api = useApi<T>(options);

  const del = useCallback(() => {
    return api.execute(url, {
      method: "DELETE",
    });
  }, [url, api]);

  return { ...api, delete: del };
}
